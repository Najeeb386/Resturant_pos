import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/sync_service.dart';
import 'pos_view.dart';
import 'orders_view.dart';
import 'menu_view.dart';
import 'tables_view.dart';
import 'inventory_view.dart';
import 'expenses_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    PosView(),
    OrdersView(),
    TablesView(),
    MenuView(),
    InventoryView(),
    ExpensesView(),
  ];

  final List<String> _titles = const [
    'POS Terminal',
    'Orders & History',
    'Tables & Bills',
    'Menu Items',
    'Inventory',
    'Expenses',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
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
              children: const [
                Text('🍽️ DineDesk POS', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Restaurant Android Terminal', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const NavigationDrawerDestination(icon: Icon(Icons.point_of_sale), label: Text('POS Terminal')),
          const NavigationDrawerDestination(icon: Icon(Icons.receipt_long), label: Text('Orders & History')),
          const NavigationDrawerDestination(icon: Icon(Icons.table_restaurant), label: Text('Tables & Bills')),
          const NavigationDrawerDestination(icon: Icon(Icons.restaurant_menu), label: Text('Menu Items')),
          const NavigationDrawerDestination(icon: Icon(Icons.inventory), label: Text('Inventory')),
          const NavigationDrawerDestination(icon: Icon(Icons.account_balance_wallet), label: Text('Expenses')),
        ],
      ),
      body: _views[_currentIndex],
      bottomNavigationBar: MediaQuery.of(context).size.width < 768
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'POS'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.table_restaurant), label: 'Tables'),
                BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
              ],
            )
          : null,
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
              child: const Text('SYNC NOW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.black, decoration: TextDecoration.underline)),
            )
        ],
      ),
    );
  }
}
