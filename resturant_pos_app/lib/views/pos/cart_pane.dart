import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/views/pos/table_select_modal.dart';
import 'package:resturant_pos_app/core/utils/receipt_printer.dart';

class CartPane extends StatefulWidget {
  const CartPane({super.key});

  @override
  State<CartPane> createState() => _CartPaneState();
}

class _CartPaneState extends State<CartPane> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryFeeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _deliveryFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posController = Get.find<PosController>();
    final auth = authProvider.state.value;
    final taxPct = auth.restaurant?.taxPercentage ?? 0.0;

    return Obx(() {
      final posState = posController.state.value;

      // Sync controller text values with provider state only if they differ
      if (_nameController.text != (posState.customerName ?? '')) {
        _nameController.text = posState.customerName ?? '';
      }
      if (_phoneController.text != (posState.customerPhone ?? '')) {
        _phoneController.text = posState.customerPhone ?? '';
      }
      if (_addressController.text != (posState.deliveryAddress ?? '')) {
        _addressController.text = posState.deliveryAddress ?? '';
      }
      final feeText = posState.deliveryFee > 0 ? posState.deliveryFee.toString() : '';
      if (_deliveryFeeController.text != feeText) {
        _deliveryFeeController.text = feeText;
      }

      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / Active Order info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    posState.activeDraftOrderId != null ? 'Edit Bill (Draft)' : 'Current Order',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  if (posState.cart.isNotEmpty)
                    TextButton.icon(
                      onPressed: posController.clearCart,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 18),
                      label: Text('Clear', style: GoogleFonts.outfit(color: AppTheme.accentRose)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Order Type Selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'dine_in', label: Text('Dine In'), icon: Icon(Icons.table_bar_outlined)),
                  ButtonSegment(value: 'takeaway', label: Text('Takeaway'), icon: Icon(Icons.shopping_bag_outlined)),
                  ButtonSegment(value: 'delivery', label: Text('Delivery'), icon: Icon(Icons.delivery_dining_outlined)),
                ],
                selected: {posState.orderType},
                onSelectionChanged: (val) {
                  posController.setOrderType(val.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Theme.of(context).primaryColor,
                  selectedForegroundColor: Colors.white,
                ),
              ),
            ),

            // Table Selection (Only for Dine In)
            if (posState.orderType == 'dine_in') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  tileColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(Icons.table_bar, color: Theme.of(context).primaryColor),
                  title: Text(
                    posState.selectedTable != null ? 'Table ${posState.selectedTable!.tableNumber}' : 'Select Table',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const TableSelectModal(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Delivery info (Only for Delivery)
            if (posState.orderType == 'delivery') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            onChanged: (val) => posController.setCustomerDetails(name: val),
                            decoration: const InputDecoration(
                              labelText: 'Name', 
                              prefixIcon: Icon(Icons.person_outline, size: 16),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            onChanged: (val) => posController.setCustomerDetails(phone: val),
                            decoration: const InputDecoration(
                              labelText: 'Phone', 
                              prefixIcon: Icon(Icons.phone_outlined, size: 16),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            onChanged: (val) => posController.setCustomerDetails(address: val),
                            decoration: const InputDecoration(
                              labelText: 'Address', 
                              prefixIcon: Icon(Icons.map_outlined, size: 16),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _deliveryFeeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) => posController.setFinances(deliveryFee: double.tryParse(val) ?? 0.0),
                            decoration: const InputDecoration(
                              labelText: 'Charges', 
                              prefixIcon: Icon(Icons.delivery_dining_outlined, size: 16),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Cart Items Scroll List
            Expanded(
              child: posState.cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: const Color(0xFF64748B).withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Cart is empty', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: posState.cart.length,
                      itemBuilder: (context, index) {
                        final cItem = posState.cart[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              // Quantity Controls
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor, size: 22),
                                    onPressed: () => posController.updateQuantity(cItem.item.id, cItem.quantity - 1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${cItem.quantity}',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor, size: 22),
                                    onPressed: () => posController.updateQuantity(cItem.item.id, cItem.quantity + 1),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Item name
                              Expanded(
                                child: Text(
                                  cItem.item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Price (in front of the item name)
                              Text(
                                Formatters.formatCurrency(cItem.item.price * cItem.quantity),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentTeal),
                              ),
                              const SizedBox(width: 4),
                              // Delete/Trash button
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 20),
                                onPressed: () => posController.updateQuantity(cItem.item.id, 0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Finances Summary Pane
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFinanceRow(context, 'Subtotal', posState.subtotal),
                  _buildFinanceRow(context, 'Tax (${taxPct}%)', posState.getTax(taxPct)),
                  if (posState.orderType == 'delivery') _buildFinanceRow(context, 'Delivery Fee', posState.deliveryFee),
                  _buildFinanceRow(context, 'Discount', -posState.discount),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                      Text(
                        Formatters.formatCurrency(posState.getTotal(taxPct)),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Method Dropdown
                  Builder(
                    builder: (context) {
                      final rawMethods = auth.restaurant?.paymentMethods ?? 'Cash,Card';
                      final methods = rawMethods.split(',').map((m) => m.trim()).toList();
                      
                      String currentMethod = posState.paymentMethod;
                      if (!methods.contains(currentMethod) && methods.isNotEmpty) {
                        currentMethod = methods.first;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          posController.setPaymentMethod(methods.first);
                        });
                      }

                      return DropdownButtonFormField<String>(
                        value: currentMethod.isNotEmpty ? currentMethod : null,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment_outlined),
                        ),
                        items: methods
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(
                                    method,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            posController.setPaymentMethod(val);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Save Draft / Checkout Buttons
                  Row(
                    children: [
                      if (posState.orderType == 'dine_in') ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: posState.cart.isEmpty || posState.isSaving
                                ? null
                                : () async {
                                    final success = await posController.saveAsDraft();
                                    if (success) {
                                      Get.snackbar(
                                        'Draft Saved',
                                        'Bill saved as draft.',
                                        backgroundColor: Theme.of(context).primaryColor,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                            child: const Text('Save Draft'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: posState.cart.isEmpty || posState.isSaving
                              ? null
                              : () async {
                                  final success = await posController.checkout();
                                  if (success) {
                                    final completedOrder = posController.lastCompletedOrder;
                                    final cartItems = List<CartItem>.from(posController.lastCompletedItems);
                                    final selectedTable = posController.lastCompletedTable;

                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }

                                    showDialog(
                                      context: Get.context!,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline, color: AppTheme.accentEmerald),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Order Paid Successfully',
                                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          'Would you like to print the KOT or the customer receipt?',
                                          style: GoogleFonts.inter(),
                                        ),
                                        actionsAlignment: MainAxisAlignment.spaceBetween,
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text('Done', style: GoogleFonts.outfit(color: Colors.grey)),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () async {
                                                   await ReceiptPrinter.printKOT(
                                                     orderType: completedOrder?.orderType ?? 'takeaway',
                                                     items: cartItems,
                                                     table: selectedTable,
                                                     notes: completedOrder?.notes,
                                                     billNumber: completedOrder?.billNumber != null ? '${completedOrder!.billNumber}' : completedOrder?.id.substring(0, 8).toUpperCase(),
                                                   );
                                                },
                                                icon: const Icon(Icons.kitchen),
                                                label: const Text('KOT'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Theme.of(context).primaryColor,
                                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  if (completedOrder != null) {
                                                    await ReceiptPrinter.printReceipt(
                                                      order: completedOrder,
                                                      items: cartItems,
                                                      restaurant: authProvider.state.value.restaurant,
                                                      table: selectedTable,
                                                    );
                                                  }
                                                },
                                                icon: const Icon(Icons.print, color: Colors.white, size: 18),
                                                label: Text(
                                                  'Receipt',
                                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                          child: const Text('Pay Bill'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinanceRow(BuildContext context, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
          Text(
            Formatters.formatCurrency(amount),
            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
