import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    List<OrderModel> filteredOrders = provider.orders.where((o) {
      if (_filter == 'completed') return o.status == 'completed';
      if (_filter == 'cancelled') return o.status == 'cancelled';
      if (_filter == 'pending_sync') return !o.synced;
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', 'All Orders (${provider.orders.length})'),
                  const SizedBox(width: 8),
                  _filterChip('completed', 'Completed'),
                  const SizedBox(width: 8),
                  _filterChip('pending_sync', 'Pending Sync (${provider.pendingSyncCount})'),
                  const SizedBox(width: 8),
                  _filterChip('cancelled', 'Cancelled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: order.synced ? Colors.green.shade50 : Colors.amber.shade50,
                            child: Icon(
                              order.synced ? Icons.cloud_done : Icons.cloud_off,
                              color: order.synced ? Colors.green : Colors.amber.shade800,
                            ),
                          ),
                          title: Text(
                            'Order #${order.localId.length > 6 ? order.localId.substring(order.localId.length - 6) : order.localId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${order.customerName} • ${order.orderType.toUpperCase()} • ${order.createdAt.split('T')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            'Rs ${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Order Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  ...order.items.map((i) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${i.qty}x ${i.name}'),
                                            Text('Rs ${(i.price * i.qty).toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      )),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Status: ${order.status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Sync: ${order.synced ? "Synced to Cloud" : "Stored Offline"}',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: order.synced ? Colors.green : Colors.amber.shade800)),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    bool isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _filter = key),
      selectedColor: Colors.deepOrange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
