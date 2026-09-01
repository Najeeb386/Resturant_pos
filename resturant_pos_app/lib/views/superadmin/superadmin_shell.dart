import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/views/landing_view.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_dashboard_view.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_restaurants_view.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_expenses_view.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_plans_view.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_profile_view.dart';

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const SuperAdminDashboardView(),
    const SuperAdminRestaurantsView(),
    const SuperAdminExpensesView(),
    const SuperAdminPlansView(),
    const SuperAdminProfileView(),
  ];

  final List<String> _titles = [
    'SaaS SuperAdmin Dashboard',
    'Registered Restaurants',
    'SaaS Platform Expenses',
    'Subscription Plans',
    'SuperAdmin Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
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
      body: Row(
        children: [
          if (isTablet) ...[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: AppTheme.surfaceDark,
              indicatorColor: AppTheme.primaryDark,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
              selectedLabelTextStyle: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: GoogleFonts.inter(
                color: const Color(0xFF64748B),
              ),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('SaaS Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business),
                  label: Text('Tenants'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('SaaS Expenses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.card_membership_outlined),
                  selectedIcon: Icon(Icons.card_membership),
                  label: Text('Plans'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppTheme.borderDark),
          ],
          Expanded(child: _views[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: !isTablet
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: AppTheme.surfaceDark,
              selectedItemColor: AppTheme.primaryDark,
              unselectedItemColor: const Color(0xFF64748B),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'SaaS Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  label: 'Tenants',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'SaaS Expenses',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.card_membership_outlined),
                  label: 'Plans',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
