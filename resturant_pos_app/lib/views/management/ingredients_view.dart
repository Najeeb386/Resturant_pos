import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController(text: '0');
  final _ingUnitController = TextEditingController(text: 'kg');

  final _restockQtyController = TextEditingController();
  final _restockCostController = TextEditingController();
  String? _selectedIngredientId;

  @override
  void dispose() {
    _ingNameController.dispose();
    _ingQtyController.dispose();
    _ingUnitController.dispose();
    _restockQtyController.dispose();
    _restockCostController.dispose();
    super.dispose();
  }

  void _addIngredient() async {
    final name = _ingNameController.text.trim();
    final qty = double.tryParse(_ingQtyController.text) ?? 0.0;
    final unit = _ingUnitController.text.trim();
    final controller = Get.find<ManagementController>();

    if (name.isNotEmpty && unit.isNotEmpty) {
      await controller.addIngredient(name, qty, unit);
      _ingNameController.clear();
      _ingQtyController.text = '0';
      _ingUnitController.text = 'kg';
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _restockIngredient() async {
    final qty = double.tryParse(_restockQtyController.text) ?? 0.0;
    final cost = double.tryParse(_restockCostController.text) ?? 0.0;
    final controller = Get.find<ManagementController>();

    if (_selectedIngredientId != null && qty > 0) {
      await controller.restockIngredient(
        ingredientId: _selectedIngredientId!,
        qtyToAdd: qty,
        cost: cost,
      );
      _restockQtyController.clear();
      _restockCostController.clear();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagementController>();

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory Control',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showAddIngredientDialog(),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Raw Ingredient'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showRestockDialog(controller.ingredients),
                              icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                              label: const Text('Restock / Procure'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inventory Control',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showAddIngredientDialog(),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Raw Ingredient'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showRestockDialog(controller.ingredients),
                            icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                            label: const Text('Restock / Procure'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Current Stock levels'),
                  Tab(text: 'Procurement History'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    // Stock tab
                    Obx(() {
                      final ingredients = controller.ingredients;
                      if (ingredients.isEmpty) {
                        return Center(
                          child: Text(
                            'No ingredients configured.',
                            style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          final ing = ingredients[index];
                          final lowStock = ing.quantity < 5.0;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: lowStock
                                    ? AppTheme.accentRose.withOpacity(0.1)
                                    : AppTheme.primaryDark.withOpacity(0.1),
                                child: Icon(
                                  Icons.soup_kitchen_outlined,
                                  color: lowStock ? AppTheme.accentRose : AppTheme.primaryDark,
                                ),
                              ),
                              title: Text(
                                ing.name,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              trailing: Text(
                                '${ing.quantity} ${ing.unit}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: lowStock ? AppTheme.accentRose : AppTheme.accentEmerald,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Logs tab
                    Obx(() {
                      final logs = controller.inventoryLogs;
                      if (logs.isEmpty) {
                        return Center(
                          child: Text(
                            'No restock history logs available.',
                            style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.white10,
                                child: Icon(Icons.history, color: Colors.white),
                              ),
                              title: Text(
                                'Restocked ${log.itemName}',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              subtitle: Text(
                                'Date: ${Formatters.formatDateTime(log.date)} | Qty: ${log.quantity} ${log.unit}',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                              trailing: Text(
                                Formatters.formatCurrency(log.cost),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentRose),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Add Raw Ingredient', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ingNameController,
              decoration: const InputDecoration(
                labelText: 'Ingredient Name', 
                hintText: 'e.g. Tomato Sauce',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Initial Qty',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ingUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit', 
                      hintText: 'e.g. kg or liters',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
          ),
          ElevatedButton(
            onPressed: _addIngredient,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Add Ingredient'),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(List<LocalIngredient> currentIngredients) {
    if (currentIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add ingredients first.')),
      );
      return;
    }

    setState(() {
      _selectedIngredientId = currentIngredients.first.id;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Restock / Procurement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedIngredientId,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: const InputDecoration(
                  labelText: 'Ingredient',
                ),
                items: currentIngredients.map((ing) {
                  return DropdownMenuItem(value: ing.id, child: Text(ing.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
                }).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    _selectedIngredientId = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _restockQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity to Add',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _restockCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Procurement Cost (Rs.)',
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
              onPressed: _restockIngredient,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Restock'),
            ),
          ],
        ),
      ),
    );
  }
}
