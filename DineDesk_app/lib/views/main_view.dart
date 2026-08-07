import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/sync_service.dart';
import 'dashboard_view.dart';
import 'pos_view.dart';
import 'orders_view.dart';
import 'kitchen_view.dart';
import 'tables_view.dart';
import 'menu_view.dart';
import 'inventory_view.dart';
import 'expenses_view.dart';
import 'staff_view.dart';
import 'reports_view.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 1; // Default to POS Terminal

  final List<Widget> _views = const [
    DashboardView(),
    PosView(),
    OrdersView(),
    KitchenView(),
    TablesView(),
    MenuView(),
    InventoryView(),
    ExpensesView(),
    StaffView(),
    ReportsView(),
    SettingsView(),
  ];

  final List<String> _titles = const [
    'Dashboard Overview',
    'POS Terminal',
    'Orders & History',
    'Kitchen Display System (KDS)',
    'Tables',
    'Menu Items',
    'Inventory',
    'Expenses Tracker',
    'Staff Roster',
    'Reports & Analytics',
    'Settings & Terminal Config',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          // Sleek Active / Inactive Status Pill Badge
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: provider.syncStatus == SyncStatus.offline ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.syncStatus == SyncStatus.offline ? Colors.red.shade300 : Colors.green.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.syncStatus == SyncStatus.offline ? Colors.red.shade600 : Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  provider.syncStatus == SyncStatus.offline ? 'Inactive' : 'Active',
                  style: TextStyle(
                    color: provider.syncStatus == SyncStatus.offline ? Colors.red.shade800 : Colors.green.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshFromApi(),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
          Navigator.pop(context);
        },
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepOrange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => const Text('🍽️ DineDesk POS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Text('Restaurant Android Terminal', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const NavigationDrawerDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
          const NavigationDrawerDestination(icon: Icon(Icons.point_of_sale), label: Text('POS Terminal')),
          const NavigationDrawerDestination(icon: Icon(Icons.receipt_long), label: Text('Orders & History')),
          const NavigationDrawerDestination(icon: Icon(Icons.soup_kitchen), label: Text('Kitchen (KDS)')),
          const NavigationDrawerDestination(icon: Icon(Icons.table_restaurant), label: Text('Tables')),
          const NavigationDrawerDestination(icon: Icon(Icons.restaurant_menu), label: Text('Menu Items')),
          const NavigationDrawerDestination(icon: Icon(Icons.inventory), label: Text('Inventory')),
          const NavigationDrawerDestination(icon: Icon(Icons.account_balance_wallet), label: Text('Expenses')),
          const NavigationDrawerDestination(icon: Icon(Icons.people), label: Text('Staff Roster')),
          const NavigationDrawerDestination(icon: Icon(Icons.bar_chart), label: Text('Reports')),
          const NavigationDrawerDestination(icon: Icon(Icons.settings), label: Text('Settings')),
        ],
      ),
      body: _views[_currentIndex],
    );
  }
}
