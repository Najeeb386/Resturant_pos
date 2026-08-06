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
    'Tables & Bills',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshFromApi(),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: _buildSyncBanner(context, provider),
        ),
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
          const NavigationDrawerDestination(icon: Icon(Icons.table_restaurant), label: Text('Tables & Bills')),
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

  Widget _buildSyncBanner(BuildContext context, AppProvider provider) {
    Color bg = Colors.green.shade600;
    String text = '🟢 Online (Synced with Server)';

    if (provider.syncStatus == SyncStatus.offline) {
      bg = Colors.amber.shade800;
      text = '🟠 Offline Mode (${provider.pendingSyncCount} pending orders to sync)';
    } else if (provider.syncStatus == SyncStatus.syncing) {
      bg = Colors.blue.shade600;
      text = '🔄 Auto-Syncing pending data with server...';
    }

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          if (provider.pendingSyncCount > 0 && provider.syncStatus != SyncStatus.syncing)
            GestureDetector(
              onTap: () => provider.refreshFromApi(),
              child: const Text('SYNC NOW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
            )
        ],
      ),
    );
  }
}
