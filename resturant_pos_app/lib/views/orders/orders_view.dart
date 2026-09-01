import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/core/utils/receipt_printer.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/views/dashboard/navigation_shell.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String _activeFilter = 'All';
  String _dateFilter = 'All'; // 'All', 'Today', 'This Week', 'This Month', 'Custom'
  DateTimeRange? _customDateRange;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    final controller = ordersNotifierProvider;

    return Scaffold(
      body: Column(
        children: [
          // Filter Tabs (Status)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Draft', 'Completed', 'Cancelled', 'Returned'].map((filter) {
                  final isSelected = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _activeFilter = filter;
                            _currentPage = 1; // Reset to page 1
                          });
                        }
                      },
                      backgroundColor: AppTheme.surfaceDark,
                      selectedColor: AppTheme.primaryDark,
                      labelStyle: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Date Filter Tabs
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...['All Time', 'Today', 'This Week', 'This Month'].map((dateFilter) {
                    final filterKey = dateFilter == 'All Time' ? 'All' : dateFilter;
                    final isSelected = _dateFilter == filterKey;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(dateFilter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _dateFilter = filterKey;
                              _currentPage = 1; // Reset to page 1
                            });
                          }
                        },
                        backgroundColor: AppTheme.surfaceDark,
                        selectedColor: AppTheme.accentTeal,
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                  // Custom Date Picker chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            _dateFilter == 'Custom' && _customDateRange != null
                                ? '${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}'
                                : 'Custom Date',
                          ),
                        ],
                      ),
                      selected: _dateFilter == 'Custom',
                      onSelected: (selected) async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange: _customDateRange,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppTheme.primaryDark,
                                  onPrimary: Colors.white,
                                  surface: AppTheme.surfaceDark,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _dateFilter = 'Custom';
                            _customDateRange = picked;
                            _currentPage = 1; // Reset to page 1
                          });
                        }
                      },
                      backgroundColor: AppTheme.surfaceDark,
                      selectedColor: AppTheme.accentTeal,
                      labelStyle: GoogleFonts.outfit(
                        color: _dateFilter == 'Custom' ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: _dateFilter == 'Custom' ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              final ordersList = controller.orders;
              
              final filtered = ordersList.where((item) {
                // 1. Status Filter
                if (_activeFilter != 'All') {
                  if (item.order.status.toLowerCase() != _activeFilter.toLowerCase()) {
                    return false;
                  }
                }

                // 2. Date Filter
                final createdAt = item.order.createdAt.toLocal(); // local time comparison
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                if (_dateFilter == 'Today') {
                  final orderDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
                  if (orderDay != today) return false;
                } else if (_dateFilter == 'This Week') {
                  final weekday = now.weekday; // 1 = Monday, 7 = Sunday
                  final startOfWeek = today.subtract(Duration(days: weekday - 1));
                  final endOfWeek = startOfWeek.add(const Duration(days: 7));
                  if (createdAt.isBefore(startOfWeek) || createdAt.isAfter(endOfWeek)) {
                    return false;
                  }
                } else if (_dateFilter == 'This Month') {
                  final startOfMonth = DateTime(now.year, now.month, 1);
                  final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
                  if (createdAt.isBefore(startOfMonth) || createdAt.isAfter(endOfMonth)) {
                    return false;
                  }
                } else if (_dateFilter == 'Custom' && _customDateRange != null) {
                  final startOfDay = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
                  final endOfDay = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
                  if (createdAt.isBefore(startOfDay) || createdAt.isAfter(endOfDay)) {
                    return false;
                  }
                }

                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found for the selected criteria.',
                    style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  ),
                );
              }

              // Pagination calculation
              final totalItems = filtered.length;
              final totalPages = (totalItems / _pageSize).ceil();
              if (_currentPage > totalPages) {
                _currentPage = totalPages > 0 ? totalPages : 1;
              }
              final startIndex = (_currentPage - 1) * _pageSize;
              final endIndex = startIndex + _pageSize > totalItems ? totalItems : startIndex + _pageSize;
              final paginatedItems = filtered.sublist(startIndex, endIndex);

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: paginatedItems.length,
                      itemBuilder: (context, index) {
                        final item = paginatedItems[index];
                        return _buildOrderCard(item);
                      },
                    ),
                  ),
                  // Pagination Controls
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1}-$endIndex of $totalItems',
                            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                color: AppTheme.primaryDark,
                                disabledColor: const Color(0xFF64748B).withOpacity(0.3),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  'Page $_currentPage of $totalPages',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                color: AppTheme.primaryDark,
                                disabledColor: const Color(0xFF64748B).withOpacity(0.3),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderWithDetails details) {
    final statusColor = _getStatusColor(details.order.status);
    final paymentStatusColor = details.order.paymentStatus == 'paid' ? AppTheme.accentEmerald : AppTheme.accentRose;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetailsBottomSheet(details),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading icon
              CircleAvatar(
                backgroundColor: AppTheme.backgroundDark,
                child: Icon(
                  details.order.orderType == 'dine_in' ? Icons.restaurant : Icons.shopping_bag_outlined,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 16),
              // Middle details block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${details.order.id.substring(0, 8).toUpperCase()}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            details.order.status.toUpperCase(),
                            style: GoogleFonts.outfit(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Table: ${details.table?.tableNumber ?? "N/A"} | Items: ${details.items.fold(0, (sum, item) => sum + item.orderItem.quantity)}',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          Formatters.formatDateTime(details.order.createdAt),
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle),
                        ),
                        Text(
                          details.order.paymentStatus.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 11, color: paymentStatusColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Trailing price
              Text(
                Formatters.formatCurrency(details.order.total),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(OrderWithDetails details) {
    final notifier = ordersNotifierProvider;
    final posNotifier = posProvider;
    final isDraft = details.order.status == 'draft';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order details',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '#${details.order.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
              const Divider(color: AppTheme.borderDark, height: 24),

              // Items list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.items.length,
                itemBuilder: (context, idx) {
                  final item = details.items[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${item.orderItem.quantity}x',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.menuItem?.name ?? 'Item',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          Formatters.formatCurrency(item.orderItem.price * item.orderItem.quantity),
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(color: AppTheme.borderDark, height: 24),

              // Totals Block
              _buildRow('Subtotal', details.order.subtotal),
              _buildRow('Tax (VAT)', details.order.tax),
              if (details.order.discount > 0) _buildRow('Discount', -details.order.discount),
              if (details.order.deliveryFee > 0) _buildRow('Delivery Fee', details.order.deliveryFee),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  Text(
                    Formatters.formatCurrency(details.order.total),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentTeal, fontSize: 16),
                  ),
                ],
              ),

              const Divider(color: AppTheme.borderDark, height: 32),

              // Actions Block
              if (isDraft) ...[
                ElevatedButton(
                  onPressed: () {
                    // Load into POS cart
                    posNotifier.loadDraft(details.order.id);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Draft Loaded',
                      'Draft loaded into POS. Tap the POS tab to edit and pay.',
                      backgroundColor: AppTheme.primaryDark,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Checkout Draft Bill'),
                ),
                const SizedBox(height: 8),
              ] else ...[
                if (details.order.paymentStatus == 'unpaid') ...[
                  ElevatedButton(
                    onPressed: () async {
                      await notifier.updatePaymentStatus(details.order.id, 'paid', 'Cash');
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentEmerald, minimumSize: const Size.fromHeight(48)),
                    child: const Text('Mark Paid (Cash)'),
                  ),
                  const SizedBox(height: 8),
                ],
                if (details.order.status == 'pending') ...[
                  OutlinedButton(
                    onPressed: () async {
                      await notifier.updateOrderStatus(details.order.id, 'preparing');
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Accept & Cook'),
                  ),
                  const SizedBox(height: 8),
                ],
              ],

              // KOT / Print actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final List<CartItem> cartItems = details.items.map((i) {
                          return CartItem(
                            item: i.menuItem ?? LocalMenuItem(
                              id: i.orderItem.menuItemId,
                              restaurantId: details.order.restaurantId,
                              name: 'Unknown Item',
                              price: i.orderItem.price,
                              costPrice: i.orderItem.costPrice,
                              categoryId: '',
                              stockQuantity: 0,
                              isDeal: false,
                            ),
                            quantity: i.orderItem.quantity,
                          );
                        }).toList();
                        
                        await ReceiptPrinter.printKOT(
                          orderType: details.order.orderType,
                          items: cartItems,
                          table: details.table,
                          notes: details.order.notes,
                          billNumber: details.order.billNumber != null ? '${details.order.billNumber}' : details.order.id.substring(0, 8).toUpperCase(),
                        );
                      },
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Print KOT'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final List<CartItem> cartItems = details.items.map((i) {
                          return CartItem(
                            item: i.menuItem ?? LocalMenuItem(
                              id: i.orderItem.menuItemId,
                              restaurantId: details.order.restaurantId,
                              name: 'Unknown Item',
                              price: i.orderItem.price,
                              costPrice: i.orderItem.costPrice,
                              categoryId: '',
                              stockQuantity: 0,
                              isDeal: false,
                            ),
                            quantity: i.orderItem.quantity,
                          );
                        }).toList();

                        await ReceiptPrinter.printReceipt(
                          order: details.order,
                          items: cartItems,
                          restaurant: authProvider.state.value.restaurant,
                          table: details.table,
                        );
                      },
                      icon: const Icon(Icons.receipt_outlined, size: 16),
                      label: const Text('Print Receipt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final posController = Get.find<PosController>();
                  await posController.loadDraft(details.order.id);
                  Navigator.of(context).pop();
                  if (Get.isRegistered<NavigationController>()) {
                    Get.find<NavigationController>().navigateToPos();
                  }
                  Get.snackbar(
                    'Editing Order',
                    'Loaded order #${details.order.id.substring(0, 8).toUpperCase()} into cart. You can now modify quantities/items and pay/save.',
                    backgroundColor: AppTheme.accentAmber,
                    colorText: Colors.black,
                    duration: const Duration(seconds: 5),
                  );
                },
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: const Text('Edit Order / Modify Items', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAmber,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 8),

              // Cancel / Return button
              if (details.order.status == 'completed') ...[
                OutlinedButton(
                  onPressed: () async {
                    await notifier.returnOrder(details.order.id);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Order Returned',
                      'Order marked as returned and inventory restored.',
                      backgroundColor: AppTheme.surfaceDark,
                      colorText: Colors.white,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple, width: 1.5),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Return Order & Refund Stock'),
                ),
              ] else if (details.order.status != 'cancelled' && details.order.status != 'returned') ...[
                OutlinedButton(
                  onPressed: () async {
                    await notifier.cancelOrder(details.order.id);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Order Cancelled',
                      'Order marked as cancelled and inventory restored.',
                      backgroundColor: AppTheme.surfaceDark,
                      colorText: Colors.white,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentRose,
                    side: const BorderSide(color: AppTheme.accentRose, width: 1.5),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancel Order & Refund Stock'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13)),
          Text(
            Formatters.formatCurrency(amount),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFF94A3B8);
      case 'pending':
        return AppTheme.accentAmber;
      case 'preparing':
        return AppTheme.primaryDark;
      case 'ready':
        return AppTheme.accentTeal;
      case 'completed':
      case 'served':
        return AppTheme.accentEmerald;
      case 'cancelled':
        return AppTheme.accentRose;
      case 'returned':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}
