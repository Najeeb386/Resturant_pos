import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';

class TableSelectModal extends StatelessWidget {
  const TableSelectModal({super.key});

  @override
  Widget build(BuildContext context) {
    final managementController = Get.find<ManagementController>();
    final ordersController = Get.find<OrdersController>();
    final posController = Get.find<PosController>();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Select Table',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SizedBox(
        width: 400,
        height: 350,
        child: Obx(() {
          final tables = managementController.tables;
          final orders = ordersController.orders;

          if (tables.isEmpty) {
            return Center(
              child: Text('No tables configured.', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
            );
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              final isOccupied = table.status == 'occupied';
              
              // Clean duplicate 'table' word from string
              final String displayTableNum = table.tableNumber.toLowerCase().contains('table')
                  ? table.tableNumber.replaceAll(RegExp(r'[tT]able\s*'), '').trim()
                  : table.tableNumber;

              // Check if there is a draft order for this table
              final draftOrder = orders.firstWhere(
                (o) => o.order.tableId == table.id && o.order.status == 'draft',
                orElse: () => OrderWithDetails(
                  order: LocalOrder(
                    id: '', restaurantId: '', userId: '', orderType: '', status: '', paymentStatus: '', subtotal: 0, tax: 0, total: 0, createdAt: DateTime(2000), deliveryFee: 0.0, discount: 0.0
                  ),
                  items: [],
                ),
              );
              final hasDraft = draftOrder.order.id.isNotEmpty;

              return InkWell(
                onTap: () {
                  if (isOccupied && hasDraft) {
                    // Load draft bill
                    posController.loadDraft(draftOrder.order.id);
                  } else {
                    // Select table normally
                    posController.setSelectedTable(table);
                  }
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? AppTheme.accentRose.withOpacity(0.1)
                        : AppTheme.accentEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOccupied ? AppTheme.accentRose : AppTheme.accentEmerald,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_bar,
                        color: isOccupied ? AppTheme.accentRose : AppTheme.accentEmerald,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Table $displayTableNum',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOccupied
                            ? (hasDraft ? 'Draft Bill' : 'Occupied')
                            : 'Available',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isOccupied ? AppTheme.accentRose : AppTheme.accentEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: GoogleFonts.outfit(color: Colors.black87)),
        ),
      ],
    );
  }
}
