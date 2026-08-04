import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: provider.expenses.isEmpty
          ? const Center(child: Text('No expenses recorded.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.expenses.length,
              itemBuilder: (context, index) {
                final exp = provider.expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(Icons.receipt, color: Colors.deepOrange),
                    ),
                    title: Text(exp.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(exp.notes ?? exp.date),
                    trailing: Text(
                      'Rs ${exp.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
