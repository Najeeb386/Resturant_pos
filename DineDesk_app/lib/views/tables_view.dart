import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TablesView extends StatelessWidget {
  const TablesView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: provider.tables.isEmpty
            ? const Center(child: Text('No tables configured.'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: provider.tables.length,
                itemBuilder: (context, index) {
                  final table = provider.tables[index];
                  bool isOccupied = table.status == 'occupied';

                  return Card(
                    color: isOccupied ? Colors.red.shade50 : Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isOccupied ? Colors.red.shade200 : Colors.green.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        provider.setOrderType('dine_in');
                        provider.setSelectedTableId(table.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected Table ${table.tableNumber} for Dine In order')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Table ${table.tableNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text('${table.capacity} Seats', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOccupied ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                table.status.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
