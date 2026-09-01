import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/core/supabase/supabase_client.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/pos_provider.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';
import 'package:resturant_pos_app/providers/kitchen_provider.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';
import 'package:resturant_pos_app/views/landing_view.dart';
import 'package:resturant_pos_app/views/dashboard/navigation_shell.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_shell.dart';

import 'package:resturant_pos_app/views/auth/login_view.dart';
import 'package:resturant_pos_app/views/auth/register_view.dart';
import 'package:resturant_pos_app/views/auth/select_plan_view.dart';
import 'package:resturant_pos_app/views/auth/inactive_view.dart';
import 'package:resturant_pos_app/views/auth/forgot_password_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (with try/catch for offline/mock safety)
  await SupabaseService.initialize();

  // Initialize GetX global state controllers in dependency order
  Get.put(DatabaseController());
  Get.put(AuthController());
  Get.put(PosController());
  Get.put(OrdersController());
  Get.put(KitchenController());
  Get.put(ManagementController());
  Get.put(SuperAdminController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'Dine Desk Restaurant POS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Locked to Orange & White theme
      darkTheme: AppTheme.lightTheme,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LandingView()),
        GetPage(name: '/LoginView', page: () => const LoginView()),
        GetPage(name: '/RegisterView', page: () => const RegisterView()),
        GetPage(name: '/SelectPlanView', page: () => const SelectPlanView()),
        GetPage(name: '/InactiveView', page: () => const InactiveView()),
        GetPage(name: '/ForgotPasswordView', page: () => const ForgotPasswordView()),
        GetPage(name: '/NavigationShell', page: () => const NavigationShell()),
        GetPage(name: '/SuperAdminShell', page: () => const SuperAdminShell()),
      ],
      home: Obx(() {
        final authState = authController.state.value;
        
        if (authState.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryLight),
                  SizedBox(height: 16),
                  Text(
                    'Loading operational terminal...',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (authState.user != null) {
          final isSuperAdmin = authState.user!.roleId == 1;
          
          if (isSuperAdmin) {
            Get.find<SuperAdminController>().loadTenants();
          } else {
            Get.find<OrdersController>().bindStream();
            Get.find<KitchenController>().bindStream();
            Get.find<ManagementController>().bindStreams();
          }

          return isSuperAdmin 
              ? const SuperAdminShell() 
              : const NavigationShell();
        }
        
        return const LandingView();
      }),
    );
  }
}
