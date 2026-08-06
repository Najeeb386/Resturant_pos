import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class KitchenView extends StatefulWidget {
  const KitchenView({super.key});

  @override
  State<KitchenView> createState() => _KitchenViewState();
}

class _KitchenViewState extends State<KitchenView> {
  Timer? _realtimeTimer;

  @override
  void initState() {
    super.initState();
    // Realtime silent auto-update every 2 seconds without reload flicker
    _realtimeTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.refreshFromApi(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Active orders for kitchen display:
    // 1. Exclude 'completed' and 'cancelled' (once Mark Ready is clicked, ticket is GONE!)
    // 2. Sort LATEST ON TOP (newest orders first)
    var activeOrders = provider.orders
        .where((o) => o.status != 'completed' && o.status != 'cancelled')
        .toList();

    activeOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: activeOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.soup_kitchen_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No active kitchen tickets',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text('New orders and Dine-In bills will automatically appear here in real-time.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  final order = activeOrders[index];
                  String ticketIdStr = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;

                  bool isPreparing = order.status == 'preparing';

                  return Card(
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isPreparing ? Colors.deepOrange : Colors.red.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ticket Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Ticket #$ticketIdStr',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  order.tableId != null 
                                      ? 'TABLE ${order.tableId}'
                                      : order.orderType.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 12),

                          // Items List
                          Expanded(
                            child: ListView.builder(
                              itemCount: order.items.length,
                              itemBuilder: (context, idx) {
                                final item = order.items[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(6)),
                                        child: Text('${item.qty}x', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 12)),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Action Button: One-tap Mark Ready -> Immediately removes ticket!
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPreparing ? Colors.green : Colors.deepOrange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                if (isPreparing) {
                                  // Mark ready -> status completed -> ticket disappears!
                                  provider.updateOrderStatus(order.localId, 'completed');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ticket #$ticketIdStr Marked Ready & Cleared!'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
                                  );
                                } else {
                                  // Transition to preparing
                                  provider.updateOrderStatus(order.localId, 'preparing');
                                }
                              },
                              icon: Icon(isPreparing ? Icons.check_circle : Icons.soup_kitchen, color: Colors.white, size: 16),
                              label: Text(
                                isPreparing ? 'MARK READY ✓' : 'START PREPARING',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
