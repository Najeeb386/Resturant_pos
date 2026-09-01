import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as d;
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';

class ReceiptPrinter {
  static Future<List<Map<String, dynamic>>> getDealItemsWithNames(String dealId) async {
    final db = databaseProvider;
    final query = db.select(db.localDealItems).join([
      d.leftOuterJoin(db.localMenuItems, db.localMenuItems.id.equalsExp(db.localDealItems.childItemId))
    ])..where(db.localDealItems.dealItemId.equals(dealId));

    final rows = await query.get();
    return rows.map((row) {
      final dealItem = row.readTable(db.localDealItems);
      final menuItem = row.readTableOrNull(db.localMenuItems);
      return {
        'name': menuItem?.name ?? 'Unknown Item',
        'quantity': dealItem.quantity,
      };
    }).toList();
  }
  static Future<void> printReceipt({
    required LocalOrder order,
    required List<CartItem> items,
    required LocalRestaurant? restaurant,
    required LocalTable? table,
  }) async {
    final Map<String, List<Map<String, dynamic>>> dealChildrenMap = {};
    for (final cartItem in items) {
      if (cartItem.item.isDeal) {
        final children = await getDealItemsWithNames(cartItem.item.id);
        dealChildrenMap[cartItem.item.id] = children;
      }
    }

    final pdf = pw.Document();
    
    final prefs = await SharedPreferences.getInstance();
    final superAdminContact = prefs.getString('superadmin_contact_number') ?? '';
    final bool useClassic = prefs.getBool('use_classic_print_template') ?? false;
    
    final logoUrl = restaurant?.logoUrl;
    pw.MemoryImage? logoImage;
    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(logoUrl));
        if (res.statusCode == 200) {
          logoImage = pw.MemoryImage(res.bodyBytes);
        }
      } catch (e) {
        print('Error downloading logo: $e');
      }
    }

    final taxPct = restaurant?.taxPercentage ?? 0.0;
    final formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(order.createdAt);
    final billNumStr = order.billNumber != null ? '${order.billNumber}' : order.id.substring(0, 8).toUpperCase();

    if (useClassic) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginTop: 15,
            marginBottom: 15,
            marginLeft: 15,
            marginRight: 15,
          ),
          build: (pw.Context context) {
            final courier = pw.Font.courier();
            final courierBold = pw.Font.courierBold();
            
            pw.TextStyle classicStyle({bool bold = false, double size = 10}) {
              return pw.TextStyle(
                font: bold ? courierBold : courier,
                fontSize: size,
                lineSpacing: 1.2,
              );
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  restaurant?.name.toUpperCase() ?? 'RESTAURANT RECEIPT',
                  style: classicStyle(bold: true, size: 14),
                  textAlign: pw.TextAlign.center,
                ),
                if (restaurant?.receiptHeader != null && restaurant!.receiptHeader!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    restaurant.receiptHeader!,
                    style: classicStyle(size: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.SizedBox(height: 6),
                pw.Text('====================================', style: classicStyle(bold: true)),
                pw.Text('RETAIL INVOICE', style: classicStyle(bold: true, size: 12), textAlign: pw.TextAlign.center),
                pw.Text('====================================', style: classicStyle(bold: true)),
                pw.SizedBox(height: 4),
                pw.Text('DATE: $formattedDate', style: classicStyle()),
                pw.Text('BILL NO: $billNumStr', style: classicStyle(bold: true, size: 11)),
                pw.Text('CUSTOMER: ${(order.customerName ?? 'Walk-in Guest').toUpperCase()}', style: classicStyle(bold: true)),
                if (order.orderType == 'dine_in' && table != null)
                  pw.Text('TABLE NO: ${table.tableNumber}', style: classicStyle(bold: true, size: 11)),
                pw.Text('PAYMENT: ${(order.paymentMethod ?? 'Cash').toUpperCase()}', style: classicStyle()),
                pw.SizedBox(height: 6),
                pw.Text('------------------------------------', style: classicStyle()),
                
                // Table of items
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3.5),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('ITEM', style: classicStyle(bold: true, size: 9)),
                        pw.Text('QTY', style: classicStyle(bold: true, size: 9), textAlign: pw.TextAlign.center),
                        pw.Text('AMOUNT', style: classicStyle(bold: true, size: 9), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    ...items.map((item) {
                      final totalAmt = item.item.price * item.quantity;
                      return pw.TableRow(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.item.name.toUpperCase(), style: classicStyle(size: 9)),
                              if (item.item.isDeal && dealChildrenMap.containsKey(item.item.id))
                                ...dealChildrenMap[item.item.id]!.map((child) => pw.Text(
                                      '  - ${child['quantity']}x ${child['name']}'.toUpperCase(),
                                      style: classicStyle(size: 8),
                                    )),
                            ],
                          ),
                          pw.Text('${item.quantity}', style: classicStyle(size: 9), textAlign: pw.TextAlign.center),
                          pw.Text(Formatters.formatCurrency(totalAmt).replaceAll('Rs. ', ''), style: classicStyle(size: 9), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.Text('------------------------------------', style: classicStyle()),
                
                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SUB TOTAL', style: classicStyle(size: 10)),
                    pw.Text(Formatters.formatCurrency(order.subtotal).replaceAll('Rs. ', ''), style: classicStyle(size: 10)),
                  ],
                ),
                if (order.discount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('(-) DISCOUNT', style: classicStyle(size: 10)),
                      pw.Text(Formatters.formatCurrency(order.discount).replaceAll('Rs. ', ''), style: classicStyle(size: 10)),
                    ],
                  ),
                if (order.tax > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TAX @ ${taxPct.toStringAsFixed(2)}%', style: classicStyle(size: 10)),
                      pw.Text(Formatters.formatCurrency(order.tax).replaceAll('Rs. ', ''), style: classicStyle(size: 10)),
                    ],
                  ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('GRAND TOTAL', style: classicStyle(bold: true, size: 13)),
                    pw.Text(Formatters.formatCurrency(order.total), style: classicStyle(bold: true, size: 13)),
                  ],
                ),
                pw.Text('====================================', style: classicStyle(bold: true)),
                
                pw.Text(
                  'THANK YOU! VISIT AGAIN.',
                  style: classicStyle(bold: true, size: 9),
                  textAlign: pw.TextAlign.center,
                ),
                if (restaurant?.receiptFooter != null && restaurant!.receiptFooter!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    restaurant.receiptFooter!,
                    style: classicStyle(size: 9),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.SizedBox(height: 4),
                pw.Text(
                  'POWERED BY DINE DESK',
                  style: classicStyle(size: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginTop: 10,
            marginBottom: 10,
            marginLeft: 10,
            marginRight: 10,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (logoImage != null) ...[
                  pw.Center(
                    child: pw.Container(
                      width: 40,
                      height: 40,
                      margin: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                ],
                if (logoImage == null) ...[
                  pw.Text(
                    restaurant?.name ?? 'Dine Desk POS',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.Text(
                  (restaurant?.receiptHeader != null && restaurant!.receiptHeader!.trim().isNotEmpty)
                      ? restaurant.receiptHeader!
                      : 'S USMAN ROAD, T. NAGAR,\nCHENNAI, TAMIL NADU.\nPHONE: 044 258636222\nGSTIN: 33AAAGP0685F1ZH',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.Text(
                  'Retail Invoice',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 2),
                pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Customer: ${order.customerName ?? 'Walk-in Guest'}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                if (order.orderType == 'delivery') ...[
                  if (order.customerPhone != null && order.customerPhone!.trim().isNotEmpty)
                    pw.Text('Contact: ${order.customerPhone}', style: const pw.TextStyle(fontSize: 8)),
                  if (order.deliveryAddress != null && order.deliveryAddress!.trim().isNotEmpty)
                    pw.Text('Address: ${order.deliveryAddress}', style: const pw.TextStyle(fontSize: 8)),
                ],
                pw.Text('Bill No: $billNumStr', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Payment Mode: ${order.paymentMethod ?? 'Cash'}', style: const pw.TextStyle(fontSize: 8)),
                if (order.orderType == 'dine_in' && table != null)
                  pw.Text('DR Ref: Table ${table.tableNumber}', style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 5),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                // Table of items
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Item', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        pw.Text('Amt', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    ...items.map((item) {
                      final totalAmt = item.item.price * item.quantity;
                      return pw.TableRow(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.item.name, style: const pw.TextStyle(fontSize: 8)),
                              if (item.item.isDeal && dealChildrenMap.containsKey(item.item.id))
                                ...dealChildrenMap[item.item.id]!.map((child) => pw.Text(
                                      '  - ${child['quantity']}x ${child['name']}',
                                      style: pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
                                    )),
                            ],
                          ),
                          pw.Text('${item.quantity}', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
                          pw.Text(Formatters.formatCurrency(totalAmt).replaceAll('Rs. ', ''), style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub Total', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(Formatters.formatCurrency(order.subtotal).replaceAll('Rs. ', ''), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                if (order.discount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('(-) Discount', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(Formatters.formatCurrency(order.discount).replaceAll('Rs. ', ''), style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                if (order.tax > 0) ...[
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax @ ${taxPct.toStringAsFixed(2)}%', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(Formatters.formatCurrency(order.tax).replaceAll('Rs. ', ''), style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(Formatters.formatCurrency(order.total), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                // Tender details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${order.paymentMethod ?? 'Cash'} :', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(Formatters.formatCurrency(order.total), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Cash tendered:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(Formatters.formatCurrency(order.total), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.Text(
                  'E & O.E',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Thank You! Visit Again.',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                if ((superAdminContact.isNotEmpty ? superAdminContact : restaurant?.receiptFooter) != null && 
                    (superAdminContact.isNotEmpty ? superAdminContact : restaurant?.receiptFooter)!.trim().isNotEmpty) ...[
                  pw.Text(
                    'Contact: ${superAdminContact.isNotEmpty ? superAdminContact : restaurant?.receiptFooter}',
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
                pw.Text(
                  'Powered by Dine Desk',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'receipt_$billNumStr',
    );
  }

  static Future<void> printKOT({
    required String orderType,
    required List<CartItem> items,
    required LocalTable? table,
    required String? notes,
    String? billNumber,
  }) async {
    final Map<String, List<Map<String, dynamic>>> dealChildrenMap = {};
    for (final cartItem in items) {
      if (cartItem.item.isDeal) {
        final children = await getDealItemsWithNames(cartItem.item.id);
        dealChildrenMap[cartItem.item.id] = children;
      }
    }

    final pdf = pw.Document();
    final formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    final bool useClassic = prefs.getBool('use_classic_print_template') ?? false;

    if (useClassic) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginTop: 15,
            marginBottom: 15,
            marginLeft: 15,
            marginRight: 15,
          ),
          build: (pw.Context context) {
            final courier = pw.Font.courier();
            final courierBold = pw.Font.courierBold();
            
            pw.TextStyle classicStyle({bool bold = false, double size = 11}) {
              return pw.TextStyle(
                font: bold ? courierBold : courier,
                fontSize: size,
                lineSpacing: 1.2,
              );
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  'KITCHEN ORDER TICKET',
                  style: classicStyle(bold: true, size: 14),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  '(KOT)',
                  style: classicStyle(bold: true, size: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text('====================================', style: classicStyle(bold: true)),
                pw.Text('DATE: $formattedDate', style: classicStyle()),
                if (billNumber != null)
                  pw.Text('KOT / BILL NO: $billNumber', style: classicStyle(bold: true, size: 13)),
                pw.Text('ORDER TYPE: ${orderType.toUpperCase()}', style: classicStyle(bold: true)),
                if (orderType == 'dine_in' && table != null)
                  pw.Text('TABLE NO: ${table.tableNumber}', style: classicStyle(bold: true, size: 14)),
                pw.Text('====================================', style: classicStyle(bold: true)),
                pw.SizedBox(height: 6),
                
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('ITEM', style: classicStyle(bold: true, size: 11)),
                        pw.Text('QTY', style: classicStyle(bold: true, size: 11), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    ...items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.item.name.toUpperCase(), style: classicStyle(bold: true, size: 12)),
                              if (item.item.isDeal && dealChildrenMap.containsKey(item.item.id))
                                ...dealChildrenMap[item.item.id]!.map((child) => pw.Text(
                                      '  - ${child['quantity']}x ${child['name']}'.toUpperCase(),
                                      style: classicStyle(bold: true, size: 10),
                                    )),
                            ],
                          ),
                          pw.Text('${item.quantity}', style: classicStyle(bold: true, size: 14), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  pw.Text('------------------------------------', style: classicStyle()),
                  pw.Text('INSTRUCTIONS: ${notes.toUpperCase()}', style: classicStyle(bold: true, size: 11)),
                ],
                pw.Text('====================================', style: classicStyle(bold: true)),
                pw.Text(
                  '* KOT COPY *',
                  style: classicStyle(bold: true, size: 11),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80.copyWith(
            marginTop: 10,
            marginBottom: 10,
            marginLeft: 10,
            marginRight: 10,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  'KITCHEN ORDER TICKET',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  '(KOT)',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 8)),
                if (billNumber != null)
                  pw.Text('Bill No: $billNumber', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('Order Type: ${orderType.toUpperCase()}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                if (orderType == 'dine_in' && table != null)
                  pw.Text('TABLE: ${table.tableNumber}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                // KOT Items
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Item', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ],
                    ),
                    ...items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.item.name, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              if (item.item.isDeal && dealChildrenMap.containsKey(item.item.id))
                                ...dealChildrenMap[item.item.id]!.map((child) => pw.Text(
                                      '  - ${child['quantity']}x ${child['name']}',
                                      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                                    )),
                            ],
                          ),
                          pw.Text('${item.quantity}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                if (notes != null && notes.isNotEmpty) ...[
                  pw.Divider(borderStyle: pw.BorderStyle.dashed),
                  pw.Text('Instructions: $notes', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.Text(
                  '* KOT COPY *',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'kot_${billNumber ?? DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
