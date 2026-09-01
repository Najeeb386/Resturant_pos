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
                      String orderIdShort = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showOrderActionsModal(context, provider, order),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: order.synced ? Colors.green.shade50 : Colors.amber.shade50,
                                  child: Icon(
                                    order.synced ? Icons.cloud_done : Icons.cloud_off,
                                    color: order.synced ? Colors.green : Colors.amber.shade800,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order #$orderIdShort',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${order.customerName} • ${order.orderType.toUpperCase()} • ${order.items.length} items',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs ${order.total.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: order.status == 'cancelled' ? Colors.red.shade50 : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: order.status == 'cancelled' ? Colors.red : Colors.green.shade800,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
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

  void _showOrderActionsModal(BuildContext context, AppProvider provider, OrderModel order) {
    String orderIdShort = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order #$orderIdShort Options',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text('${order.customerName} • Rs ${order.total.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            // Option 1: Edit Order Items & Customer Info
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showEditOrderDialog(context, provider, order);
              },
              icon: const Icon(Icons.edit_square, color: Colors.white),
              label: const Text('Edit / Add Items to Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // Option 2: Cancel Order
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                provider.cancelOrder(order.localId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order Cancelled!'), backgroundColor: Colors.red),
                );
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel Order', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            // Option 3: View Receipt
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showReceiptDialog(context, order);
              },
              icon: const Icon(Icons.receipt_long, color: Colors.blue),
              label: const Text('View Receipt / Bill', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOrderDialog(BuildContext context, AppProvider provider, OrderModel order) {
    List<CartItem> editableItems = List.from(order.items);
    final nameController = TextEditingController(text: order.customerName);
    MenuItem? selectedNewItem;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double subtotal = editableItems.fold(0.0, (sum, i) => sum + (i.price * i.qty));
          double tax = subtotal * 0.10;
          double total = subtotal + tax + order.deliveryFee;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Edit Order #${order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Order Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    ...editableItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      if (item.qty > 1) {
                                        item.qty--;
                                      } else {
                                        editableItems.remove(item);
                                      }
                                    });
                                  },
                                ),
                                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.deepOrange),
                                  onPressed: () {
                                    setState(() {
                                      item.qty++;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // Add new item dropdown
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<MenuItem>(
                              isExpanded: true,
                              hint: const Text('Add item from menu...', style: TextStyle(fontSize: 12)),
                              value: selectedNewItem,
                              items: provider.menuItems.map((m) {
                                return DropdownMenuItem<MenuItem>(
                                  value: m,
                                  child: Text('${m.name} (Rs ${m.price.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => selectedNewItem = val);
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_box, color: Colors.deepOrange, size: 28),
                          onPressed: selectedNewItem == null
                              ? null
                              : () {
                                  setState(() {
                                    int existingIdx = editableItems.indexWhere((i) => i.menuItemId == selectedNewItem!.id);
                                    if (existingIdx > -1) {
                                      editableItems[existingIdx].qty++;
                                    } else {
                                      editableItems.add(CartItem(
                                        menuItemId: selectedNewItem!.id,
                                        cartKey: '${selectedNewItem!.id}',
                                        name: selectedNewItem!.name,
                                        price: selectedNewItem!.price,
                                        qty: 1,
                                      ));
                                    }
                                    selectedNewItem = null;
                                  });
                                },
                        )
                      ],
                    ),
                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Updated Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rs ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: () {
                  OrderModel updatedOrder = OrderModel(
                    localId: order.localId,
                    serverId: order.serverId,
                    tableId: order.tableId,
                    orderType: order.orderType,
                    customerName: nameController.text.trim().isEmpty ? 'Walk-in' : nameController.text.trim(),
                    customerPhone: order.customerPhone,
                    deliveryAddress: order.deliveryAddress,
                    subtotal: subtotal,
                    tax: tax,
                    deliveryFee: order.deliveryFee,
                    total: total,
                    paymentMethod: order.paymentMethod,
                    paymentStatus: order.paymentStatus,
                    status: order.status,
                    synced: false,
                    createdAt: order.createdAt,
                    items: editableItems,
                  );

                  provider.updateOrder(updatedOrder);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order changes saved successfully!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, OrderModel order) {
    String orderIdShort = order.localId.length >= 4 ? order.localId.substring(order.localId.length - 4) : order.localId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('RECEIPT PREVIEW', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Text('Order #$orderIdShort', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Center(child: Text(order.createdAt.split('T')[0], style: const TextStyle(color: Colors.grey, fontSize: 11))),
              const Divider(),
              ...order.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.qty}x ${i.name}', style: const TextStyle(fontSize: 13)),
                        Text('Rs ${(i.price * i.qty).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(color: Colors.grey)),
                  Text('Rs ${order.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax (10%):', style: TextStyle(color: Colors.grey)),
                  Text('Rs ${order.tax.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Rs ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'POWERED BY DINEDESK',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.print, color: Colors.white, size: 18),
            label: const Text('Print Receipt', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
