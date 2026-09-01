import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Rent';
  final List<String> _categories = ['Rent', 'Utilities', 'Salaries', 'Ingredients', 'Procurement', 'Marketing', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addExpense() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final controller = Get.find<ManagementController>();

    if (name.isNotEmpty && amount > 0) {
      await controller.addExpense(
        name,
        amount,
        _selectedCategory,
        DateTime.now(),
        null,
      );
      _nameController.clear();
      _amountController.clear();
      _selectedCategory = 'Rent';
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManagementController>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operating Costs',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final expenses = controller.expenses;
                
                if (expenses.isEmpty) {
                  return Center(
                    child: Text(
                      'No operating expenses logged.',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final exp = expenses[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accentRose.withOpacity(0.1),
                          child: const Icon(Icons.trending_down, color: AppTheme.accentRose),
                        ),
                        title: Text(exp.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        subtitle: Text(
                          'Category: ${exp.category} | Date: ${Formatters.formatDate(exp.date)}',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.formatCurrency(exp.amount),
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentRose, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.accentRose, size: 18),
                              onPressed: () {
                                controller.deleteExpense(exp.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Log Operating Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name/Description', 
                  hintText: 'e.g. Electricity Bill',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Rs.)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));
                }).toList(),
                onChanged: (val) {
                  setDialogState(() {
                    _selectedCategory = val!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor)),
            ),
            ElevatedButton(
              onPressed: _addExpense,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Log Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
