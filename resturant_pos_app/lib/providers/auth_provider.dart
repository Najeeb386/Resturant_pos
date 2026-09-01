import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/core/database/database_seeder.dart';
import 'package:resturant_pos_app/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:drift/drift.dart' as d;
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

import 'package:flutter/material.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/views/landing_view.dart';
import 'package:resturant_pos_app/views/dashboard/navigation_shell.dart';
import 'package:resturant_pos_app/views/superadmin/superadmin_shell.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';
import 'package:resturant_pos_app/providers/kitchen_provider.dart';
import 'package:resturant_pos_app/providers/management_providers.dart';
import 'package:resturant_pos_app/providers/superadmin_provider.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final LocalUser? user;
  final LocalRestaurant? restaurant;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.restaurant,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    LocalUser? user,
    LocalRestaurant? restaurant,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      restaurant: restaurant ?? this.restaurant,
    );
  }
}

class AuthController extends GetxController {
  final Rx<AuthState> state = AuthState().obs;
  bool _isInitialLoad = true;

  @override
  void onInit() {
    super.onInit();
    
    LocalUser? lastUser = state.value.user;
    ever(state, (AuthState current) {
      if (!current.isLoading) {
        if (_isInitialLoad) {
          _isInitialLoad = false;
          lastUser = current.user;
          return;
        }

        final userChanged = (lastUser == null && current.user != null) || (lastUser != null && current.user == null);
        lastUser = current.user;

        if (!userChanged) {
          return;
        }

        if (current.user != null) {
          final isSuperAdmin = current.user!.roleId == 1;
          if (isSuperAdmin) {
            Get.find<SuperAdminController>().loadTenants();
          } else {
            Get.find<OrdersController>().bindStream();
            Get.find<KitchenController>().bindStream();
            Get.find<ManagementController>().bindStreams();
          }

          if (isSuperAdmin) {
            Get.offAll(() => const SuperAdminShell());
          } else {
            Get.offAll(() => const NavigationShell());
          }
        } else {
          Get.offAll(() => const LandingView());
        }
      }
    });

    loadSession();
  }

  Future<void> loadSession() async {
    state.value = state.value.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('cached_user');
    final restJson = prefs.getString('cached_restaurant');

    if (userJson != null && restJson != null) {
      try {
        final dbUser = LocalUser.fromJson(jsonDecode(userJson));
        final dbRest = LocalRestaurant.fromJson(jsonDecode(restJson));
        state.value = AuthState(user: dbUser, restaurant: dbRest);
        // Silently sync in background
        syncManagerProvider.syncQueue();
        syncManagerProvider.startPeriodicSync(dbRest.id);
      } catch (e) {
        state.value = AuthState();
      }
    } else {
      state.value = AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    final cleanEmail = email.trim().toLowerCase();
    try {
      final supa = SupabaseService.instance;
      
      // Simulating credentials check if Supabase URL is default
      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        if (cleanEmail.contains('@') && password.length >= 6) {
          final mockRestId = const Uuid().v4();
          final mockUserId = const Uuid().v4();
          
          final dbUser = LocalUser(
            id: mockUserId,
            name: cleanEmail.split('@').first.toUpperCase(),
            email: cleanEmail,
            roleId: cleanEmail == 'admin@dinedesk.com' || cleanEmail.contains('superadmin')
                ? 1
                : (cleanEmail.contains('admin') ? 2 : 3),
            restaurantId: mockRestId,
          );
          
          final dbRest = LocalRestaurant(
            id: mockRestId,
            name: "Tasty Station",
            currency: "USD",
            currencySymbol: "\$",
            taxPercentage: 18.0,
            kitchenBypass: false,
            paymentMethods: 'Cash,Card',
            planName: 'Premium SaaS',
            hasKitchen: true,
            hasStaff: true,
            hasInventory: true,
            startingBillNumber: 1000,
          );

          final db = databaseProvider;
          await db.clearAllData();
          await db.into(db.localUsers).insertOnConflictUpdate(dbUser);
          await db.into(db.localRestaurants).insertOnConflictUpdate(dbRest);

          await _saveSession(dbUser, dbRest);
          state.value = AuthState(user: dbUser, restaurant: dbRest);
          return true;
        } else {
          state.value = state.value.copyWith(isLoading: false, error: "Invalid credentials format");
          return false;
        }
      }

      final response = await supa.login(cleanEmail, password);
      if (response.user == null) {
        state.value = state.value.copyWith(isLoading: false, error: 'User not found');
        return false;
      }

      if (cleanEmail == 'admin@dinedesk.com' || cleanEmail.contains('superadmin')) {
        final restId = '00000000-0000-0000-0000-000000000000';
        
        // 1. Provision default SaaS Admin restaurant
        await supa.client.from('restaurants').upsert({
          'id': restId,
          'name': 'SaaS Administration',
          'currency': 'PKR',
          'currency_symbol': 'Rs. ',
          'tax_percentage': 18.0,
          'kitchen_bypass': false,
        });

        // 2. Provision the user profile forcing role_id = 1
        await supa.client.from('users').upsert({
          'id': response.user!.id,
          'name': cleanEmail.split('@').first.toUpperCase(),
          'email': cleanEmail,
          'role_id': 1, // SuperAdmin
          'restaurant_id': restId,
        });
      }

      // Fetch user data from table
      var userData = await supa.client
          .from('users')
          .select('*, restaurants(*)')
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        state.value = state.value.copyWith(
          isLoading: false,
          error: 'User profile not found. Please register your restaurant first.',
        );
        return false;
      }

      final dbUser = LocalUser(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        roleId: userData['role_id'],
        restaurantId: userData['restaurant_id'],
      );

      final rawRestData = userData['restaurants'];
      final Map<String, dynamic> restData;
      if (rawRestData is List) {
        restData = rawRestData.isNotEmpty ? Map<String, dynamic>.from(rawRestData.first) : {};
      } else if (rawRestData is Map) {
        restData = Map<String, dynamic>.from(rawRestData);
      } else {
        restData = {};
      }

      // Fetch plan details from Supabase if online
      final planName = restData['plan_name'] ?? 'Premium SaaS';
      bool hasKitchen = true;
      bool hasStaff = true;
      bool hasInventory = true;

      try {
        final planRes = await supa.client
            .from('subscription_plans')
            .select()
            .eq('name', planName)
            .maybeSingle();

        if (planRes != null) {
          final String rawDesc = planRes['description'] ?? '';
          if (rawDesc.contains('|__FEATURES__Detailed:')) {
            final parts = rawDesc.split('|__FEATURES__Detailed:');
            final Map<String, dynamic> feats = jsonDecode(parts[1]);
            hasKitchen = feats['hasKitchen'] ?? true;
            hasStaff = feats['hasStaff'] ?? true;
            hasInventory = feats['hasInventory'] ?? true;
          }
        }
      } catch (e) {
        print('Error resolving plan features from Supabase: $e');
      }

      final dbRest = LocalRestaurant(
        id: restData['id'] ?? '',
        name: restData['name'] ?? '',
        currency: restData['currency'] ?? 'USD',
        currencySymbol: restData['currency_symbol'] ?? '\$',
        taxPercentage: (restData['tax_percentage'] as num?)?.toDouble() ?? 0.0,
        logoUrl: restData['logo_url'],
        receiptHeader: restData['receipt_header'],
        receiptFooter: restData['receipt_footer'],
        kitchenBypass: restData['kitchen_bypass'] ?? false,
        paymentMethods: restData['payment_methods'] ?? 'Cash,Card',
        planName: planName,
        hasKitchen: hasKitchen,
        hasStaff: hasStaff,
        hasInventory: hasInventory,
        startingBillNumber: restData['starting_bill_number'] ?? 1000,
      );

      // Verify subscription / restaurant account status
      final String restStatus = restData['status'] ?? 'Active';
      if (dbUser.roleId != 1 && restStatus != 'Active' && restStatus != 'Trial') {
        state.value = state.value.copyWith(
          isLoading: false,
          error: 'INACTIVE_ACCOUNT',
        );
        return false;
      }

      // Save locally
      final db = databaseProvider;
      await db.clearAllData();
      await db.into(db.localUsers).insertOnConflictUpdate(dbUser);
      await db.into(db.localRestaurants).insertOnConflictUpdate(dbRest);

      await _saveSession(dbUser, dbRest);
      state.value = AuthState(user: dbUser, restaurant: dbRest);

      // Start periodic sync (which triggers download immediately)
      syncManagerProvider.startPeriodicSync(dbRest.id);

      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> registerRestaurant({
    required String restaurantName,
    required String adminName,
    required String email,
    required String password,
    required String selectedPlan,
  }) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final supa = SupabaseService.instance;
      final restId = const Uuid().v4();
      final userId = const Uuid().v4();

      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        // Mock offline registration
        final dbUser = LocalUser(
          id: userId,
          name: adminName,
          email: email,
          roleId: 2, // Admin
          restaurantId: restId,
        );
        final plansCtrl = superAdminProvider;
        final planModel = plansCtrl.plans.firstWhereOrNull((p) => p.name == selectedPlan);
        final dbRest = LocalRestaurant(
          id: restId,
          name: restaurantName,
          currency: 'USD',
          currencySymbol: '\$',
          taxPercentage: 18.0,
          kitchenBypass: false,
          paymentMethods: 'Cash,Card',
          planName: selectedPlan,
          hasKitchen: planModel?.hasKitchen ?? true,
          hasStaff: planModel?.hasStaff ?? true,
          hasInventory: planModel?.hasInventory ?? true,
          startingBillNumber: 1000,
        );
        final db = databaseProvider;
        await db.clearAllData();
        await db.into(db.localUsers).insertOnConflictUpdate(dbUser);
        await db.into(db.localRestaurants).insertOnConflictUpdate(dbRest);

        await _saveSession(dbUser, dbRest);
        state.value = AuthState(user: dbUser, restaurant: dbRest);
        return true;
      }

      // 1. SignUp user in Supabase Auth
      final response = await supa.register(email, password);
      if (response.user == null) {
        state.value = state.value.copyWith(isLoading: false, error: 'Registration failed');
        return false;
      }

      final restData = await supa.client.from('restaurants').insert({
        'id': restId,
        'name': restaurantName,
        'currency': 'PKR',
        'currency_symbol': 'Rs. ',
        'tax_percentage': 18.0,
        'kitchen_bypass': false,
        'plan_name': selectedPlan,
        'status': 'Trial',
      }).select().single();

      // 3. Create User Row in users table
      final userData = await supa.client.from('users').insert({
        'id': response.user!.id,
        'name': adminName,
        'email': email,
        'role_id': 2, // Admin
        'restaurant_id': restId,
      }).select().single();

      final dbUser = LocalUser(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        roleId: userData['role_id'],
        restaurantId: userData['restaurant_id'],
      );

      // Fetch plan details from Supabase if online
      final planName = restData['plan_name'] ?? 'Premium SaaS';
      bool hasKitchen = true;
      bool hasStaff = true;
      bool hasInventory = true;

      try {
        final planRes = await supa.client
            .from('subscription_plans')
            .select()
            .eq('name', planName)
            .maybeSingle();

        if (planRes != null) {
          final String rawDesc = planRes['description'] ?? '';
          if (rawDesc.contains('|__FEATURES__Detailed:')) {
            final parts = rawDesc.split('|__FEATURES__Detailed:');
            final Map<String, dynamic> feats = jsonDecode(parts[1]);
            hasKitchen = feats['hasKitchen'] ?? true;
            hasStaff = feats['hasStaff'] ?? true;
            hasInventory = feats['hasInventory'] ?? true;
          }
        }
      } catch (e) {
        print('Error resolving plan features from Supabase: $e');
      }

      final dbRest = LocalRestaurant(
        id: restData['id'],
        name: restData['name'],
        currency: restData['currency'],
        currencySymbol: restData['currency_symbol'],
        taxPercentage: (restData['tax_percentage'] as num).toDouble(),
        kitchenBypass: restData['kitchen_bypass'] ?? false,
        paymentMethods: restData['payment_methods'] ?? 'Cash,Card',
        planName: planName,
        hasKitchen: hasKitchen,
        hasStaff: hasStaff,
        hasInventory: hasInventory,
        startingBillNumber: restData['starting_bill_number'] ?? 1000,
      );

      final db = databaseProvider;
      await db.clearAllData();
      await db.into(db.localUsers).insertOnConflictUpdate(dbUser);
      await db.into(db.localRestaurants).insertOnConflictUpdate(dbRest);

      await _saveSession(dbUser, dbRest);
      state.value = AuthState(user: dbUser, restaurant: dbRest);
      syncManagerProvider.startPeriodicSync(dbRest.id);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> _saveSession(LocalUser user, LocalRestaurant rest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', jsonEncode(user.toJson()));
    await prefs.setString('cached_restaurant', jsonEncode(rest.toJson()));
  }

  Future<void> updateLocalCachedSession(LocalRestaurant rest) async {
    final authState = state.value;
    if (authState.user != null) {
      await _saveSession(authState.user!, rest);
      state.value = AuthState(user: authState.user, restaurant: rest);
    }
  }

  Future<void> logout() async {
    syncManagerProvider.stopPeriodicSync();
    state.value = state.value.copyWith(isLoading: true);
    try {
      final supa = SupabaseService.instance;
      if (!SupabaseService.supabaseUrl.contains('your-project-id')) {
        await supa.logout();
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
    await prefs.remove('cached_restaurant');

    final db = databaseProvider;
    await db.clearAllData();

    state.value = AuthState();
  }
  Future<bool> updateRestaurantProfile({
    required String name,
    required double taxPercentage,
    String? logoUrl,
    required String paymentMethods,
    required bool kitchenBypass,
    String? receiptHeader,
    int? startingBillNumber,
  }) async {
    final authState = state.value;
    if (authState.restaurant == null) return false;

    try {
      final db = databaseProvider;
      final sync = syncManagerProvider;
      
      final updatedRest = authState.restaurant!.copyWith(
        name: name,
        taxPercentage: taxPercentage,
        logoUrl: d.Value(logoUrl),
        paymentMethods: paymentMethods,
        kitchenBypass: kitchenBypass,
        receiptHeader: d.Value(receiptHeader),
        startingBillNumber: startingBillNumber != null ? startingBillNumber : authState.restaurant!.startingBillNumber,
      );

      // 1. Update SQLite Local DB
      await (db.update(db.localRestaurants)
            ..where((t) => t.id.equals(authState.restaurant!.id)))
          .write(
        LocalRestaurantsCompanion(
          name: d.Value(name),
          taxPercentage: d.Value(taxPercentage),
          logoUrl: d.Value(logoUrl),
          paymentMethods: d.Value(paymentMethods),
          kitchenBypass: d.Value(kitchenBypass),
          receiptHeader: d.Value(receiptHeader),
          startingBillNumber: startingBillNumber != null ? d.Value(startingBillNumber) : const d.Value.absent(),
        ),
      );

      // 2. Update cached session in SharedPreferences
      await _saveSession(authState.user!, updatedRest);

      // 3. Update active AuthState
      state.value = AuthState(user: authState.user, restaurant: updatedRest);

      // 4. Queue sync to Supabase
      await sync.queueAction(
        actionType: 'UPDATE',
        tableName: 'restaurants',
        recordId: authState.restaurant!.id,
        payload: {
          'id': authState.restaurant!.id,
          'name': name,
          'tax_percentage': taxPercentage,
          'logo_url': logoUrl,
          'payment_methods': paymentMethods,
          'kitchen_bypass': kitchenBypass,
          'receipt_header': receiptHeader,
          'starting_bill_number': startingBillNumber,
        },
      );

      return true;
    } catch (e) {
      print('ERROR updating restaurant profile: $e');
      return false;
    }
  }

  Future<bool> createStaffUser({
    required String name,
    required String email,
    required String password,
    required int roleId,
  }) async {
    final authState = state.value;
    if (authState.restaurant == null) {
      state.value = state.value.copyWith(error: 'Active restaurant not found');
      return false;
    }
    
    final restaurantId = authState.restaurant!.id;

    try {
      final supa = SupabaseService.instance;
      
      // Initialize a temporary secondary SupabaseClient to create user without overriding current admin session
      final tempClient = SupabaseClient(
        SupabaseService.supabaseUrl,
        SupabaseService.supabaseAnonKey,
        authOptions: AuthClientOptions(
          pkceAsyncStorage: MockAsyncStorage(),
        ),
      );

      // 1. Sign up the user in Supabase Auth
      final signUpResponse = await tempClient.auth.signUp(
        email: email,
        password: password,
      );

      if (signUpResponse.user == null) {
        throw Exception('Failed to sign up user in Supabase Auth');
      }

      final newUserId = signUpResponse.user!.id;

      // 2. Insert user record into the public 'users' table using primary client
      await supa.client.from('users').insert({
        'id': newUserId,
        'name': name,
        'email': email,
        'role_id': roleId,
        'restaurant_id': restaurantId,
      });

      // 3. Insert staff user locally into SQLite so they are cached right away
      final db = databaseProvider;
      final localStaffUser = LocalUser(
        id: newUserId,
        name: name,
        email: email,
        roleId: roleId,
        restaurantId: restaurantId,
      );
      await db.into(db.localUsers).insertOnConflictUpdate(localStaffUser);

      return true;
    } catch (e) {
      print('ERROR creating staff user: $e');
      state.value = state.value.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteStaffUser(String userId) async {
    try {
      final supa = SupabaseService.instance;
      
      // 1. Delete from Supabase public users table
      await supa.client.from('users').delete().eq('id', userId);
      
      // 2. Delete locally from SQLite
      final db = databaseProvider;
      await (db.delete(db.localUsers)..where((t) => t.id.equals(userId))).go();
      
      return true;
    } catch (e) {
      print('ERROR deleting staff user: $e');
      state.value = state.value.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> handleSuspendedRestaurant() async {
    // 1. Terminate sync loops
    syncManagerProvider.stopPeriodicSync();
    
    // 2. Clear state and cache
    state.value = AuthState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
    await prefs.remove('cached_restaurant');
    
    final db = databaseProvider;
    await db.clearAllData();
    
    // 3. Route cleanly to InactiveView
    Get.offAllNamed('/InactiveView');
  }

  Future<bool> sendOtp(String email) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final cleanEmail = email.trim().toLowerCase();
      
      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        // Mock OTP generation
        final mockOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
        // Save the mock otp locally in preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mock_forgot_otp_$cleanEmail', mockOtp);
        
        // Show OTP to user in snackbar for local/mock flow
        Get.snackbar(
          'Mock Email Sent',
          'OTP Code for $cleanEmail is $mockOtp',
          backgroundColor: AppTheme.accentAmber,
          colorText: Colors.black,
          duration: const Duration(seconds: 10),
        );
        state.value = state.value.copyWith(isLoading: false);
        return true;
      }
      
      final supa = SupabaseService.instance;
      // In Supabase, signInWithOtp with shouldCreateUser: false sends code to existing user
      await supa.client.auth.signInWithOtp(
        email: cleanEmail,
        shouldCreateUser: false,
      );
      
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanOtp = otp.trim();
      
      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString('mock_forgot_otp_$cleanEmail');
        if (cached == cleanOtp) {
          state.value = state.value.copyWith(isLoading: false);
          return true;
        } else {
          state.value = state.value.copyWith(isLoading: false, error: 'Invalid OTP code');
          return false;
        }
      }
      
      final supa = SupabaseService.instance;
      final response = await supa.client.auth.verifyOTP(
        email: cleanEmail,
        token: cleanOtp,
        type: OtpType.recovery,
      );
      
      // If recovery fails, try email otp type as fallback
      if (response.user == null) {
        try {
          await supa.client.auth.verifyOTP(
            email: cleanEmail,
            token: cleanOtp,
            type: OtpType.email,
          );
        } catch (_) {}
      }
      
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateForgottenPassword(String email, String newPassword) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        // Mock offline password update (no-op success)
        state.value = state.value.copyWith(isLoading: false);
        return true;
      }
      
      final supa = SupabaseService.instance;
      // Since user is logged in after verifyOTP, we can update password on their session
      await supa.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      // Sign out clean after changing password
      await supa.client.auth.signOut();
      
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        state.value = state.value.copyWith(isLoading: false);
        return true;
      }
      
      final supa = SupabaseService.instance;
      await supa.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePlatformContact(String contact) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('superadmin_contact_number', contact);

      if (SupabaseService.supabaseUrl.contains('your-project-id')) {
        return true;
      }

      final supa = SupabaseService.instance;
      // Update all restaurants' receipt footer on Supabase
      await supa.client.from('restaurants').update({
        'receipt_footer': contact,
      }).neq('name', '');
      return true;
    } catch (e) {
      print('Error updating platform contact: $e');
      return false;
    }
  }
}

AuthController get authProvider => Get.find<AuthController>();

class MockAsyncStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> setItem({required String key, required String value}) async {}

  @override
  Future<void> removeItem({required String key}) async {}
}
