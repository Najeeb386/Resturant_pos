import 'package:flutter/material.dart';

class StaffView extends StatelessWidget {
  const StaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> staffList = [
      {'name': 'Restaurant Owner', 'email': 'owner@restaurant.com', 'role': 'Owner'},
      {'name': 'John Cashier', 'email': 'cashier@restaurant.com', 'role': 'Cashier'},
      {'name': 'Sarah Chef', 'email': 'kitchen@restaurant.com', 'role': 'Chef'},
      {'name': 'Alex Waiter', 'email': 'waiter@restaurant.com', 'role': 'Waitstaff'},
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff member management modal opened')),
          );
        },
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrange.shade50,
                child: const Icon(Icons.person, color: Colors.deepOrange),
              ),
              title: Text(staff['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(staff['email']!),
              trailing: Chip(
                label: Text(staff['role']!, style: TextStyle(color: Colors.deepOrange.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                backgroundColor: Colors.orange.shade50,
              ),
            ),
          );
        },
      ),
    );
  }
}
