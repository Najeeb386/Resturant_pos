import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:drift/drift.dart' as d;

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _selectedRange = 'This Month'; // 'Today', 'This Week', 'This Month', 'Custom Range', 'All Time'
  int _activeTab = 0; // 0 for Cash Flow, 1 for Product Sales, 2 for Delivery Charges
  
  // Custom range selection
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Loaded indicators data
  double _cashIn = 0.0;
  double _cashOut = 0.0;
  double _netProfit = 0.0;
  double _totalDeliveryFees = 0.0;
  List<Map<String, dynamic>> _movements = [];
  List<Map<String, dynamic>> _productSales = [];
  List<LocalOrder> _deliveryOrdersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    final db = databaseProvider;
    final restaurantId = authProvider.state.value.restaurant?.id ?? '';

    // Fetch all completed orders
    final orders = await (db.select(db.localOrders)
          ..where((t) => t.restaurantId.equals(restaurantId) & t.status.equals('completed')))
        .get();

    // Fetch all expenses
    final expenses = await (db.select(db.localExpenses)
          ..where((t) => t.restaurantId.equals(restaurantId)))
        .get();

    final now = DateTime.now();
    DateTime filterStartDate;
    DateTime filterEndDate = DateTime(2100, 1, 1);

    switch (_selectedRange) {
      case 'Today':
        filterStartDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        filterStartDate = now.subtract(Duration(days: now.weekday - 1));
        filterStartDate = DateTime(filterStartDate.year, filterStartDate.month, filterStartDate.day);
        break;
      case 'This Month':
        filterStartDate = DateTime(now.year, now.month, 1);
        break;
      case 'Custom Range':
        filterStartDate = _customStartDate ?? DateTime(now.year, now.month, now.day);
        filterStartDate = DateTime(filterStartDate.year, filterStartDate.month, filterStartDate.day, 0, 0, 0);
        
        final endVal = _customEndDate ?? now;
        filterEndDate = DateTime(endVal.year, endVal.month, endVal.day, 23, 59, 59);
        break;
      case 'All Time':
      default:
        filterStartDate = DateTime(2000, 1, 1);
        break;
    }

    // Filter orders
    final filteredOrders = orders.where((o) => o.createdAt.isAfter(filterStartDate) && o.createdAt.isBefore(filterEndDate)).toList();
    // Filter expenses
    final filteredExpenses = expenses.where((e) => e.date.isAfter(filterStartDate) && e.date.isBefore(filterEndDate)).toList();

    // Aggregate totals
    final cashIn = filteredOrders.fold(0.0, (sum, o) => sum + o.total);
    final cashOut = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Merge transactions into timeline log
    final List<Map<String, dynamic>> movements = [];

    for (final order in filteredOrders) {
      movements.add({
        'type': 'inflow',
        'title': 'Order Checkout (#${order.id.substring(0, 6).toUpperCase()})',
        'subtitle': 'Payment Mode: ${order.paymentMethod ?? "Cash"}',
        'amount': order.total,
        'date': order.createdAt,
      });
    }

    for (final exp in filteredExpenses) {
      movements.add({
        'type': 'outflow',
        'title': 'Expense: ${exp.category} - ${exp.name}',
        'subtitle': exp.notes ?? 'No description',
        'amount': exp.amount,
        'date': exp.date,
      });
    }

    // Sort movements by date descending
    movements.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Fetch all menu items and categories to map names and categories dynamically
    final menuItems = await (db.select(db.localMenuItems)
          ..where((t) => t.restaurantId.equals(restaurantId)))
        .get();
    final Map<String, LocalMenuItem> menuItemMap = {
      for (final item in menuItems) item.id: item
    };

    final categories = await db.select(db.localMenuCategories).get();
    final Map<String, String> categoryMap = {
      for (final cat in categories) cat.id: cat.name
    };

    // Query order items for filtered orders
    final List<Map<String, dynamic>> productSales = [];
    if (filteredOrders.isNotEmpty) {
      final orderIds = filteredOrders.map((o) => o.id).toList();
      final orderItems = await (db.select(db.localOrderItems)
            ..where((t) => t.orderId.isIn(orderIds)))
          .get();

      final Map<String, Map<String, dynamic>> salesMap = {};
      for (final oItem in orderItems) {
        final mItem = menuItemMap[oItem.menuItemId];
        final itemName = mItem?.name ?? 'Deleted Item';
        final categoryId = mItem?.categoryId ?? '';
        final categoryName = categoryMap[categoryId] ?? 'General';

        if (salesMap.containsKey(oItem.menuItemId)) {
          final current = salesMap[oItem.menuItemId]!;
          current['quantity'] = (current['quantity'] as double) + oItem.quantity;
          current['total_sales'] = (current['total_sales'] as double) + (oItem.price * oItem.quantity);
        } else {
          salesMap[oItem.menuItemId] = {
            'id': oItem.menuItemId,
            'name': itemName,
            'category': categoryName,
            'price': oItem.price,
            'quantity': oItem.quantity.toDouble(),
            'total_sales': oItem.price * oItem.quantity,
          };
        }
      }
      productSales.addAll(salesMap.values.toList());
      // Sort by quantity sold descending
      productSales.sort((a, b) => (b['quantity'] as double).compareTo(a['quantity'] as double));
    }

    // Filter delivery orders
    final deliveryOrders = filteredOrders.where((o) => o.orderType == 'delivery').toList();
    final totalDeliveryFees = deliveryOrders.fold(0.0, (sum, o) => sum + o.deliveryFee);

    setState(() {
      _cashIn = cashIn;
      _cashOut = cashOut;
      _netProfit = cashIn - cashOut;
      _totalDeliveryFees = totalDeliveryFees;
      _movements = movements;
      _productSales = productSales;
      _deliveryOrdersList = deliveryOrders;
      _isLoading = false;
    });
  }

  Widget _buildTabButton(int index, String title) {
    final isActive = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Performance',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  if (_selectedRange == 'Custom Range' && _customStartDate != null && _customEndDate != null) ...[
                    TextButton.icon(
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(
                        '${DateFormat('dd/MM/yy').format(_customStartDate!)} - ${DateFormat('dd/MM/yy').format(_customEndDate!)}',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: DateTimeRange(start: _customStartDate!, end: _customEndDate!),
                        );
                        if (picked != null) {
                          setState(() {
                            _customStartDate = picked.start;
                            _customEndDate = picked.end;
                          });
                          _loadReportData();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  DropdownButton<String>(
                    value: _selectedRange,
                    dropdownColor: Theme.of(context).cardColor,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                      DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      DropdownMenuItem(value: 'Custom Range', child: Text('Custom Range')),
                      DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                    ],
                    onChanged: (val) async {
                      if (val == 'Custom Range') {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: _customStartDate != null && _customEndDate != null
                              ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
                              : DateTimeRange(
                                  start: DateTime.now().subtract(const Duration(days: 7)),
                                  end: DateTime.now(),
                                ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedRange = val!;
                            _customStartDate = picked.start;
                            _customEndDate = picked.end;
                          });
                          _loadReportData();
                        }
                      } else if (val != null) {
                        setState(() {
                          _selectedRange = val;
                        });
                        _loadReportData();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Tab Selector Row
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'Cash Flow'),
                  _buildTabButton(1, 'Product Sales'),
                  _buildTabButton(2, 'Delivery Charges'),
                ],
              ),
            ),

            if (_activeTab == 0) ...[
              // KPI Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 32) / 3;
                  final isCompact = constraints.maxWidth < 600;

                  Widget buildSummaryGrid() {
                    final cards = [
                      _buildKpiCard(
                        title: 'Cash In (Revenue)',
                        value: Formatters.formatCurrency(_cashIn),
                        icon: Icons.trending_up,
                        color: AppTheme.accentEmerald,
                      ),
                      _buildKpiCard(
                        title: 'Cash Out (Expenses)',
                        value: Formatters.formatCurrency(_cashOut),
                        icon: Icons.trending_down,
                        color: AppTheme.accentRose,
                      ),
                      _buildKpiCard(
                        title: 'Net Cash Flow',
                        value: Formatters.formatCurrency(_netProfit),
                        icon: _netProfit >= 0 ? Icons.monetization_on : Icons.money_off,
                        color: _netProfit >= 0 ? AppTheme.accentEmerald : AppTheme.accentRose,
                      ),
                    ];

                    if (isCompact) {
                      return Column(
                        children: cards.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(width: double.infinity, child: c),
                        )).toList(),
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
                    );
                  }

                  return buildSummaryGrid();
                },
              ),
              const SizedBox(height: 24),

              // Cash movements title
              Text(
                'Timeline Log',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Timeline movement log
              Expanded(
                child: _movements.isEmpty
                    ? Center(
                        child: Text(
                          'No financial entries found for this range.',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _movements.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final move = _movements[index];
                          final isInflow = move['type'] == 'inflow';
                          final dateStr = DateFormat('dd MMM, hh:mm a').format(move['date'] as DateTime);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: isInflow
                                  ? AppTheme.accentEmerald.withOpacity(0.15)
                                  : AppTheme.accentRose.withOpacity(0.15),
                              child: Icon(
                                isInflow ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isInflow ? AppTheme.accentEmerald : AppTheme.accentRose,
                              ),
                            ),
                            title: Text(
                              move['title'],
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${move['subtitle']} • $dateStr',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: Text(
                              '${isInflow ? "+" : "-"}${Formatters.formatCurrency(move['amount'])}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isInflow ? AppTheme.accentEmerald : AppTheme.accentRose,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ] else if (_activeTab == 1) ...[
              // Product Sales List View
              Text(
                'Sold Items Summary',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _productSales.isEmpty
                    ? Center(
                        child: Text(
                          'No items sold in this range.',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _productSales.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final sale = _productSales[index];
                          final qty = (sale['quantity'] as double).toInt();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                              child: Text(
                                sale['name'].isNotEmpty ? sale['name'].substring(0, 1).toUpperCase() : 'P',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            title: Text(
                              sale['name'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Category: ${sale['category']} • Price: ${Formatters.formatCurrency(sale['price'])}',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$qty pcs sold',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Formatters.formatCurrency(sale['total_sales']),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentEmerald,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ] else ...[
              // Delivery Charges Summary
              LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 16) / 2;
                  final isCompact = constraints.maxWidth < 600;

                  final cards = [
                    _buildKpiCard(
                      title: 'Delivery Fees Collected',
                      value: Formatters.formatCurrency(_totalDeliveryFees),
                      icon: Icons.delivery_dining,
                      color: AppTheme.accentTeal,
                    ),
                    _buildKpiCard(
                      title: 'Total Delivery Orders',
                      value: '${_deliveryOrdersList.length} Orders',
                      icon: Icons.local_shipping_outlined,
                      color: AppTheme.primaryDark,
                    ),
                  ];

                  if (isCompact) {
                    return Column(
                      children: cards.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(width: double.infinity, child: c),
                      )).toList(),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                'Delivery Collection Log',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _deliveryOrdersList.isEmpty
                    ? Center(
                        child: Text(
                          'No delivery orders found for this range.',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _deliveryOrdersList.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final order = _deliveryOrdersList[index];
                          final dateStr = DateFormat('dd MMM, hh:mm a').format(order.createdAt);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentTeal.withOpacity(0.15),
                              child: Icon(Icons.delivery_dining, color: AppTheme.accentTeal),
                            ),
                            title: Text(
                              order.customerName ?? 'Guest Customer',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (order.customerPhone != null && order.customerPhone!.trim().isNotEmpty)
                                  Text('Phone: ${order.customerPhone}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                if (order.deliveryAddress != null && order.deliveryAddress!.trim().isNotEmpty)
                                  Text('Address: ${order.deliveryAddress}', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                                Text('Date: $dateStr', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.withOpacity(0.8))),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '+${Formatters.formatCurrency(order.deliveryFee)}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.accentTeal,
                                  ),
                                ),
                                Text(
                                  'Bill: ${Formatters.formatCurrency(order.total)}',
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
