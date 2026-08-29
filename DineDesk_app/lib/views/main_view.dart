import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
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
import 'threed_studio_view.dart';
import 'login_view.dart';

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
    ThreeDStudioView(),
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
    '3D Floor Plan Studio',
    'Settings & Terminal Config',
  ];

  final List<String> _featureKeys = const [
    'dashboard',
    'pos_billing',
    'orders',
    'kitchen',
    'tables',
    'menu',
    'inventory',
    'expenses',
    'staff',
    'reports',
    '3d_studio',
    'settings',
  ];

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout from Terminal?'),
        content: const Text('Are you sure you want to log out of your DineDesk POS session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ApiService.logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // 1. Check 7-Day Offline Lockout Rule
    if (provider.isOfflineLocked) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.red.shade900.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Offline Usage Limit Reached',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This terminal has been operating offline for ${provider.offlineDaysCount} days. To ensure data integrity and subscription validity, please connect to the internet to sync with DineDesk server.',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.sync, color: Colors.white),
                      label: const Text('Connect Internet & Sync Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await provider.refreshFromApi();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Check Subscription Status Lockout Rule
    if (provider.isSubscriptionLocked) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.amber.shade900.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_clock, size: 64, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Subscription ${provider.subscriptionStatus.toUpperCase()}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your restaurant subscription plan is currently ${provider.subscriptionStatus}. Please renew your subscription plan via the web admin portal to restore terminal access.',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Re-check Subscription Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await provider.refreshFromApi();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    label: const Text('Logout', style: TextStyle(color: Colors.white70)),
                    onPressed: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 3. Normal App Shell
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          // Network Sync Pill Badge
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
                  provider.syncStatus == SyncStatus.offline ? 'Offline' : 'Online',
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
            tooltip: 'Sync Data',
            onPressed: () => provider.refreshFromApi(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          String key = _featureKeys[idx];
          if (key != 'dashboard' && key != 'settings' && !provider.isFeatureAllowed(key)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⚠️ Feature not included in your current subscription plan.')),
            );
            return;
          }
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
                  height: 44,
                  errorBuilder: (context, error, stackTrace) => const Text('🍽️ DineDesk POS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Text('Restaurant Cross-Platform Terminal', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          _buildDrawerDestination(0, Icons.dashboard, 'Dashboard', 'dashboard', provider),
          _buildDrawerDestination(1, Icons.point_of_sale, 'POS Terminal', 'pos_billing', provider),
          _buildDrawerDestination(2, Icons.receipt_long, 'Orders & History', 'orders', provider),
          _buildDrawerDestination(3, Icons.soup_kitchen, 'Kitchen (KDS)', 'kitchen', provider),
          _buildDrawerDestination(4, Icons.table_restaurant, 'Tables', 'tables', provider),
          _buildDrawerDestination(5, Icons.restaurant_menu, 'Menu Items', 'menu', provider),
          _buildDrawerDestination(6, Icons.inventory, 'Inventory', 'inventory', provider),
          _buildDrawerDestination(7, Icons.account_balance_wallet, 'Expenses', 'expenses', provider),
          _buildDrawerDestination(8, Icons.people, 'Staff Roster', 'staff', provider),
          _buildDrawerDestination(9, Icons.bar_chart, 'Reports', 'reports', provider),
          _buildDrawerDestination(10, Icons.view_in_ar, '3D Floor Studio', '3d_studio', provider),
          _buildDrawerDestination(11, Icons.settings, 'Settings', 'settings', provider),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout Terminal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
          ),
        ],
      ),
      body: _views[_currentIndex],
    );
  }

  NavigationDrawerDestination _buildDrawerDestination(int index, IconData icon, String label, String featureKey, AppProvider provider) {
    bool isAllowed = featureKey == 'dashboard' || featureKey == 'settings' || provider.isFeatureAllowed(featureKey);

    return NavigationDrawerDestination(
      icon: Icon(icon, color: isAllowed ? null : Colors.grey),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isAllowed ? null : Colors.grey)),
          if (!isAllowed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 10, color: Colors.grey),
                  SizedBox(width: 2),
                  Text('Locked', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
