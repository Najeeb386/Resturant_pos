import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/utils/formatters.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

class SuperAdminExpensesView extends StatelessWidget {
  const SuperAdminExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = superAdminProvider;

    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Server';
    DateTime selectedDate = DateTime.now();

    void showAddExpenseDialog() {
      Get.dialog(
        StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: Text(
              'Log SaaS Expense',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Expense Description',
                      hintText: 'e.g. AWS hosting fees',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (USD)',
                      hintText: 'e.g. 75.50',
                      labelStyle: TextStyle(color: Colors.black54),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Operational Category',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Server', child: Text('Server & Hosting', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Domain', child: Text('Domain Registrations', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Marketing', child: Text('Marketing & Ads', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Support', child: Text('Customer Support', style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: 'Other', child: Text('Other Overhead', style: TextStyle(color: Colors.black))),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedCategory = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Date',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      child: Text(
                        Formatters.formatDate(selectedDate),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.black54)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final desc = descriptionController.text.trim();
                  final amt = double.tryParse(amountController.text.trim()) ?? 0.0;

                  if (desc.isNotEmpty && amt > 0) {
                    await controller.addSaaSExpense(
                      description: desc,
                      amount: amt,
                      category: selectedCategory,
                      date: selectedDate,
                    );
                    descriptionController.clear();
                    amountController.clear();
                    Get.back();
                    Get.snackbar(
                      'Expense Logged',
                      'SaaS Operational cost logged successfully.',
                      backgroundColor: AppTheme.accentEmerald,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAddExpenseDialog,
        backgroundColor: AppTheme.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SaaS Operational Costs & Profits',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            
            // Financial Summary Row
            Obx(() {
              final mrr = controller.mrr;
              final expenseTotal = controller.totalExpenses;
              final profit = controller.netProfit;
              final isCompact = MediaQuery.of(context).size.width < 600;

              final cards = [
                _buildFinancialCard(
                  context,
                  'Gross SaaS MRR',
                  Formatters.formatCurrency(mrr),
                  AppTheme.accentEmerald,
                  Icons.arrow_upward,
                ),
                _buildFinancialCard(
                  context,
                  'SaaS Platform Expenses',
                  Formatters.formatCurrency(expenseTotal),
                  AppTheme.accentRose,
                  Icons.arrow_downward,
                ),
                _buildFinancialCard(
                  context,
                  'Net SaaS Profit',
                  Formatters.formatCurrency(profit),
                  profit >= 0 ? AppTheme.accentTeal : AppTheme.accentRose,
                  Icons.monetization_on_outlined,
                ),
              ];

              if (isCompact) {
                return Column(
                  children: cards.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(width: double.infinity, child: c),
                  )).toList(),
                );
              }

              return Row(
                children: cards.map((c) => Expanded(child: c)).toList(),
              );
            }),
            const SizedBox(height: 24),
            
            // Expenses History Label
            Text(
              'Expense History List',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            
            // Expenses List
            Expanded(
              child: Obx(() {
                if (controller.saasExpenses.isEmpty) {
                  return Center(
                    child: Text(
                      'No operational expenses logged yet.',
                      style: GoogleFonts.inter(color: Colors.black38),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.saasExpenses.length,
                  itemBuilder: (context, index) {
                    final exp = controller.saasExpenses[index];
                    IconData iconData = Icons.dns;
                    if (exp.category == 'Domain') iconData = Icons.language;
                    if (exp.category == 'Marketing') iconData = Icons.campaign;
                    if (exp.category == 'Support') iconData = Icons.support_agent;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.backgroundDark,
                          child: Icon(iconData, color: AppTheme.accentTeal, size: 20),
                        ),
                        title: Text(
                          exp.description,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          'Category: ${exp.category} | ${Formatters.formatDate(exp.date)}',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                        trailing: Text(
                          Formatters.formatCurrency(exp.amount),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.accentRose, fontSize: 15),
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

  Widget _buildFinancialCard(BuildContext context, String title, String val, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.backgroundDark,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(val, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
