import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Filter today's orders (matching Web Dashboard logic)
    DateTime now = DateTime.now();
    List<OrderModel> todayOrders = provider.orders.where((o) {
      if (o.status == 'cancelled') return false;
      DateTime? dt = DateTime.tryParse(o.createdAt);
      if (dt == null) return true;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();

    double todaySales = todayOrders.fold(0.0, (sum, o) => sum + o.total);
    int todayOrderCount = todayOrders.length;
    int activeOrdersCount = provider.orders.where((o) => o.status == 'pending' || o.status == 'preparing').length;
    int lowStockCount = provider.menuItems.where((i) => i.stockQuantity <= 10).length;

    // Compute last 7 days sales data for Weekly Sales Chart
    List<Map<String, dynamic>> weeklySales = [];
    double maxSales = 100.0;

    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

      double dayTotal = provider.orders.where((o) {
        if (o.status == 'cancelled') return false;
        DateTime? dt = DateTime.tryParse(o.createdAt);
        if (dt == null) return false;
        return dt.year == date.year && dt.month == date.month && dt.day == date.day;
      }).fold(0.0, (sum, o) => sum + o.total);

      if (dayTotal > maxSales) maxSales = dayTotal;

      weeklySales.add({
        'day': dayName,
        'date': '${date.day}/${date.month}',
        'sales': dayTotal,
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('Real-time operational summary & sales analytics', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),

            // KPI Cards Grid matching Web Dashboard
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _kpiCard(
                  'Today\'s Revenue',
                  'Rs ${todaySales.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.orange.shade800,
                  'Today live total',
                ),
                _kpiCard(
                  'Today\'s Orders',
                  '$todayOrderCount',
                  Icons.shopping_bag,
                  Colors.blue,
                  'Today total count',
                ),
                _kpiCard(
                  'Active Orders',
                  '$activeOrdersCount',
                  Icons.soup_kitchen,
                  Colors.redAccent,
                  'In active queue',
                ),
                _kpiCard(
                  'Low Stock Items',
                  '$lowStockCount',
                  Icons.inventory_2,
                  Colors.green,
                  'Needs restock',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 7-Day Weekly Sales Bar Chart (Matching Web Dashboard)
            Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('7-Day Sales Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text('Weekly Trend', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                          backgroundColor: Color(0xFFFFF3ED),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chart Bars Container
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklySales.map((d) {
                          double sales = d['sales'] as double;
                          double barHeight = (sales / maxSales) * 110;
                          if (barHeight < 8) barHeight = 8; // minimum height indicator

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                sales > 0 ? '${sales.toStringAsFixed(0)}' : '',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 28,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: sales > 0
                                        ? [Colors.deepOrange, Colors.orangeAccent]
                                        : [Colors.grey.shade300, Colors.grey.shade200],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                d['day'],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            provider.orders.isEmpty
                ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No orders recorded today.'))))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.orders.length > 5 ? 5 : provider.orders.length,
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      String orderIdShort = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade50,
                            child: const Icon(Icons.receipt_long, color: Colors.deepOrange),
                          ),
                          title: Text('Order #$orderIdShort', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${order.customerName} • ${order.orderType.toUpperCase()}'),
                          trailing: Text('Rs ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
