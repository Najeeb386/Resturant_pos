import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/views/dashboard/dashboard_view.dart';
import 'package:resturant_pos_app/views/pos/pos_view.dart';
import 'package:resturant_pos_app/views/orders/orders_view.dart';
import 'package:resturant_pos_app/views/kitchen/kitchen_view.dart';
import 'package:resturant_pos_app/views/management/tables_manage_view.dart';
import 'package:resturant_pos_app/views/management/menu_manage_view.dart';
import 'package:resturant_pos_app/views/management/ingredients_view.dart';
import 'package:resturant_pos_app/views/management/expenses_view.dart';
import 'package:resturant_pos_app/views/landing_view.dart';
import 'package:resturant_pos_app/views/settings/settings_view.dart';
import 'package:resturant_pos_app/views/reports/reports_view.dart';
import 'package:resturant_pos_app/views/management/staff_view.dart';

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void navigateToPos() {
    final roleId = authProvider.state.value.user?.roleId ?? 2;
    if (roleId == 4) return;
    if (roleId == 3) {
      selectedIndex.value = 0;
    } else {
      selectedIndex.value = 1;
    }
  }
}

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  final NavigationController _navController = Get.put(NavigationController());

  Map<String, dynamic> _getMenuConfig(int roleId) {
    if (roleId == 4) {
      // Kitchen Staff
      return {
        'views': [const KitchenView()],
        'titles': ['Kitchen Monitor'],
        'icons': [Icons.kitchen_outlined],
        'rail': const [
          NavigationRailDestination(
            icon: Icon(Icons.kitchen_outlined),
            label: Text('Kitchen'),
          ),
        ]
      };
    } else if (roleId == 3) {
      // Cashier
      return {
        'views': [
          const PosView(),
          const OrdersView(),
          const TablesManageView(),
        ],
        'titles': [
          'POS Terminal',
          'Orders & Bills',
          'Table Layout',
        ],
        'icons': [
          Icons.point_of_sale_outlined,
          Icons.receipt_long_outlined,
          Icons.table_bar_outlined,
        ],
        'rail': const [
          NavigationRailDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            label: Text('POS'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: Text('Orders'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.table_bar_outlined),
            label: Text('Tables'),
          ),
        ]
      };
    } else {
      // Admin (roleId == 2)
      final rest = authProvider.state.value.restaurant;
      final bool hasKitchen = rest?.hasKitchen ?? true;
      final bool hasStaff = rest?.hasStaff ?? true;
      final bool hasInventory = rest?.hasInventory ?? true;

      final List<Widget> finalViews = [];
      final List<String> finalTitles = [];
      final List<IconData> finalIcons = [];
      final List<NavigationRailDestination> finalRail = [];

      void addOption(Widget view, String title, IconData icon, NavigationRailDestination dest) {
        finalViews.add(view);
        finalTitles.add(title);
        finalIcons.add(icon);
        finalRail.add(dest);
      }

      // 1. Dashboard
      addOption(
        const DashboardView(),
        'Dashboard',
        Icons.dashboard_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: Text('Stats'),
        ),
      );

      // 2. POS Terminal
      addOption(
        const PosView(),
        'POS Terminal',
        Icons.point_of_sale_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          label: Text('POS'),
        ),
      );

      // 3. Orders & Bills
      addOption(
        const OrdersView(),
        'Orders & Bills',
        Icons.receipt_long_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: Text('Orders'),
        ),
      );

      // 4. Kitchen Monitor (Conditional)
      if (hasKitchen) {
        addOption(
          const KitchenView(),
          'Kitchen Monitor',
          Icons.kitchen_outlined,
          const NavigationRailDestination(
            icon: Icon(Icons.kitchen_outlined),
            label: Text('Kitchen'),
          ),
        );
      }

      // 5. Inventory (Conditional)
      if (hasInventory) {
        addOption(
          const IngredientsView(),
          'Inventory',
          Icons.inventory_2_outlined,
          const NavigationRailDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: Text('Inventory'),
          ),
        );
      }

      // 6. Menu Manager
      addOption(
        const MenuManageView(),
        'Menu Manager',
        Icons.restaurant_menu_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          label: Text('Menu'),
        ),
      );

      // 7. Table Layout
      addOption(
        const TablesManageView(),
        'Table Layout',
        Icons.table_bar_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.table_bar_outlined),
          label: Text('Tables'),
        ),
      );

      // 8. Expenses Log
      addOption(
        const ExpensesView(),
        'Expenses Log',
        Icons.attach_money_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.attach_money_outlined),
          label: Text('Expenses'),
        ),
      );

      // 9. Financial Reports
      addOption(
        const ReportsView(),
        'Financial Reports',
        Icons.analytics_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          label: Text('Reports'),
        ),
      );

      // 10. Staff Management (Conditional)
      if (hasStaff) {
        addOption(
          const StaffView(),
          'Staff Management',
          Icons.people_outline,
          const NavigationRailDestination(
            icon: Icon(Icons.people_outline),
            label: Text('Staff'),
          ),
        );
      }

      // 11. Settings
      addOption(
        const SettingsView(),
        'Settings',
        Icons.settings_outlined,
        const NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          label: Text('Settings'),
        ),
      );

      return {
        'views': finalViews,
        'titles': finalTitles,
        'icons': finalIcons,
        'rail': finalRail,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 800;

    return Obx(() {
      final authState = authProvider.state.value;

      if (authState.user == null) {
        return const LandingView();
      }

      final roleId = authState.user!.roleId;
      final config = _getMenuConfig(roleId);
      final views = config['views'] as List<Widget>;
      final titles = config['titles'] as List<String>;
      final railDestinations = config['rail'] as List<NavigationRailDestination>;

      if (_navController.selectedIndex.value >= titles.length) {
        _navController.selectedIndex.value = 0;
      }

      return Scaffold(
        appBar: AppBar(
          leading: !isTablet
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
          title: Text(titles[_navController.selectedIndex.value]),
          actions: [
            IconButton(
              icon: Icon(Icons.sync_outlined, color: Theme.of(context).colorScheme.onBackground),
              tooltip: 'Sync Local DB',
              onPressed: () {
                authProvider.loadSession(); // Re-trigger sync
                Get.snackbar(
                  'Syncing Queue',
                  'Syncing data queue with the cloud database...',
                  backgroundColor: Theme.of(context).primaryColor,
                  colorText: Colors.white,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: AppTheme.accentRose),
              tooltip: 'Logout',
              onPressed: () async {
                await authProvider.logout();
                Get.offAll(() => const LandingView());
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        drawer: !isTablet ? _buildDrawer(context) : null,
        body: Row(
          children: [
            if (isTablet) ...[
              NavigationRail(
                selectedIndex: _navController.selectedIndex.value,
                onDestinationSelected: (int index) {
                  _navController.selectedIndex.value = index;
                },
                backgroundColor: Theme.of(context).primaryColor,
                indicatorColor: Colors.white.withOpacity(0.2),
                selectedIconTheme: const IconThemeData(color: Colors.white, size: 28),
                unselectedIconTheme: const IconThemeData(color: Colors.white70),
                selectedLabelTextStyle: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: GoogleFonts.inter(
                  color: Colors.white70,
                ),
                labelType: NavigationRailLabelType.all,
                destinations: railDestinations,
              ),
              VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).dividerColor),
            ],
            Expanded(
              child: views[_navController.selectedIndex.value],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDrawer(BuildContext context) {
    final authState = authProvider.state.value;
    final user = authState.user;
    final restaurant = authState.restaurant;
    final roleId = user?.roleId ?? 2;
    final config = _getMenuConfig(roleId);
    final titles = config['titles'] as List<String>;
    final icons = config['icons'] as List<IconData>;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                restaurant?.name.isNotEmpty == true ? restaurant!.name.substring(0, 1).toUpperCase() : 'T',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            accountName: Text(
              restaurant?.name ?? 'Dine Desk',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: List.generate(titles.length, (index) {
                final isSelected = _navController.selectedIndex.value == index;

                return ListTile(
                  leading: Icon(
                    icons[index],
                    color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF64748B),
                  ),
                  title: Text(
                    titles[index],
                    style: GoogleFonts.outfit(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () {
                    _navController.selectedIndex.value = index;
                    Navigator.of(context).pop(); // Close drawer
                  },
                );
              }),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: AppTheme.accentRose),
            title: Text(
              'Logout',
              style: GoogleFonts.outfit(color: AppTheme.accentRose, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.of(context).pop(); // Close drawer
              await authProvider.logout();
              Get.offAll(() => const LandingView());
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
