import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';

class TablesManageView extends StatefulWidget {
  const TablesManageView({super.key});

  @override
  State<TablesManageView> createState() => _TablesManageViewState();
}

class _TablesManageViewState extends State<TablesManageView> {
  final _tableNumberController = TextEditingController();
  final _capacityController = TextEditingController(text: '4');

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _addTable() async {
    final number = _tableNumberController.text.trim();
    final capacity = int.tryParse(_capacityController.text) ?? 4;
    final controller = Get.find<ManagementController>();

    if (number.isNotEmpty) {
      await controller.addTable(number, capacity);
      _tableNumberController.clear();
      _capacityController.text = '4';
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagementController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTableDialog(),
        backgroundColor: AppTheme.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        final tables = controller.tables;
        
        if (tables.isEmpty) {
          return Center(
            child: Text(
              'No tables configured.',
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
        final double childAspectRatio = width < 600 ? 0.85 : 1.1;

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.table_bar, color: AppTheme.primaryDark, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Table ${table.tableNumber}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacity: ${table.capacity} pax',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 20),
                      onPressed: () {
                        controller.deleteTable(table.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Add Table',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tableNumberController,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                hintText: 'e.g. 5 or A1',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacity (Pax)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
          ),
          ElevatedButton(
            onPressed: _addTable,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Add Table'),
          ),
        ],
      ),
    );
  }
}
