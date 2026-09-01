import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: provider.inventory.isEmpty
          ? const Center(child: Text('No raw materials in inventory.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.inventory.length,
              itemBuilder: (context, index) {
                final inv = provider.inventory[index];
                bool isLowStock = inv.quantity <= inv.minQuantity;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isLowStock ? Colors.red.shade300 : Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLowStock ? Colors.red.shade50 : Colors.blue.shade50,
                      child: Icon(
                        isLowStock ? Icons.warning_amber : Icons.inventory_2,
                        color: isLowStock ? Colors.red : Colors.blue,
                      ),
                    ),
                    title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Min Alert: ${inv.minQuantity} ${inv.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${inv.quantity} ${inv.unit}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isLowStock ? Colors.red : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
