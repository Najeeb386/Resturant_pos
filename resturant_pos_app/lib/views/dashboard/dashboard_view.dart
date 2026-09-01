import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.find<OrdersController>();
    final managementController = Get.find<ManagementController>();

    return Obx(() {
      final orders = ordersController.orders;
      final expenses = managementController.expenses;
      final categories = managementController.categories;

      // Calculations
      final completedOrders = orders.where((o) =>
          o.order.status == 'completed' ||
          o.order.status == 'served' ||
          o.order.status == 'ready' ||
          o.order.status == 'preparing' ||
          o.order.status == 'pending');
      final totalSales = completedOrders.fold(0.0, (sum, o) => sum + o.order.total);
      final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      final netProfit = totalSales - totalExpenses;
      final ordersCount = completedOrders.length;

      return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greetings
            Text(
              'Operational Insights',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Performance overview for your restaurant',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),

            // Stats row
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                if (isMobile) {
                  return Column(
                    children: [
                      _buildStatCard(context, 'Gross Sales', totalSales, Icons.attach_money_outlined, Theme.of(context).primaryColor),
                      const SizedBox(height: 12),
                      _buildStatCard(context, 'Expenses', totalExpenses, Icons.money_off_outlined, Theme.of(context).primaryColor),
                      const SizedBox(height: 12),
                      _buildStatCard(context, 'Net Profit', netProfit, Icons.trending_up_outlined, Theme.of(context).primaryColor),
                      const SizedBox(height: 12),
                      _buildStatCard(context, 'Completed Bills', ordersCount.toDouble(), Icons.receipt_long_outlined, Theme.of(context).primaryColor, isCount: true),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'Gross Sales', totalSales, Icons.attach_money_outlined, Theme.of(context).primaryColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Expenses', totalExpenses, Icons.money_off_outlined, Theme.of(context).primaryColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Net Profit', netProfit, Icons.trending_up_outlined, Theme.of(context).primaryColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Completed Bills', ordersCount.toDouble(), Icons.receipt_long_outlined, Theme.of(context).primaryColor, isCount: true)),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Charts Section
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                final orderList = completedOrders.toList();
                if (isMobile) {
                  return Column(
                    children: [
                      _buildSalesChart(context, orderList),
                      const SizedBox(height: 24),
                      _buildCategoryDistribution(orderList, categories),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildSalesChart(context, orderList)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildCategoryDistribution(orderList, categories)),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      );
    });
  }

  Widget _buildStatCard(BuildContext context, String title, double value, IconData icon, Color color, {bool isCount = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCount ? value.toInt().toString() : Formatters.formatCurrency(value),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context, List<OrderWithDetails> orders) {
    // Generate dates for the last 7 days (ending today)
    final last7Days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    final daySales = <DateTime, double>{};
    for (final date in last7Days) {
      daySales[date] = 0.0;
    }

    for (final o in orders) {
      final localDate = o.order.createdAt.toLocal();
      final orderDate = DateTime(localDate.year, localDate.month, localDate.day);
      if (daySales.containsKey(orderDate)) {
        daySales[orderDate] = daySales[orderDate]! + o.order.total;
      }
    }

    final spots = last7Days.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      return FlSpot(index.toDouble(), daySales[date] ?? 0.0);
    }).toList();

    final labels = last7Days.map((date) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    }).toList();

    // Determine max Y value for scaling
    final maxSales = daySales.values.fold(100.0, (maxVal, val) => val > maxVal ? val : maxVal);
    final roundedMaxY = ((maxSales / 100).ceil() * 100).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Trend (Last 7 Days)',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == roundedMaxY / 2 || value == roundedMaxY) {
                            return Text(
                              Formatters.formatCurrency(value),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: const Color(0xFF64748B),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[index],
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: roundedMaxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(List<OrderWithDetails> orders, List<LocalMenuCategory> categories) {
    final categorySales = <String, double>{};
    final catMap = {for (var c in categories) c.id: c.name};

    for (final o in orders) {
      for (final item in o.items) {
        if (item.menuItem != null) {
          final catName = catMap[item.menuItem!.categoryId] ?? 'Other';
          final qty = item.orderItem.quantity.toDouble();
          categorySales[catName] = (categorySales[catName] ?? 0.0) + qty;
        }
      }
    }

    final totalQuantity = categorySales.values.fold(0.0, (sum, val) => sum + val);

    final colors = [
      const Color(0xFF3B82F6), // Indigo / Royal Blue
      const Color(0xFF10B981), // Emerald / Teal
      const Color(0xFF8B5CF6), // Violet / Purple
      const Color(0xFFF59E0B), // Amber / Gold
      const Color(0xFFEF4444), // Crimson / Coral
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Rose / Pink
      const Color(0xFFF97316), // Orange
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = categorySales.entries.map((entry) {
      final catName = entry.key;
      final val = entry.value;
      final percentage = totalQuantity > 0 ? (val / totalQuantity * 100).round() : 0;
      
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: val,
        title: '$catName\n$percentage%',
        radius: 55,
        titleStyle: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // Fallback if no sales yet
    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF1E293B),
          value: 1,
          title: 'No Sales Yet',
          radius: 50,
          titleStyle: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item Breakdown',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: sections,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
