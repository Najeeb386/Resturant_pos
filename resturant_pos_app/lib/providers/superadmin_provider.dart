import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:resturant_pos_app/core/supabase/supabase_client.dart';

class TenantModel {
  final String id;
  final String name;
  final String admin;
  final String email;
  final String plan;
  final String status; // Active, Trial, Expired, Suspended
  final double sales;
  final DateTime createdAt;
  final String? phone;

  TenantModel({
    required this.id,
    required this.name,
    required this.admin,
    required this.email,
    required this.plan,
    required this.status,
    required this.sales,
    required this.createdAt,
    this.phone,
  });

  TenantModel copyWith({
    String? id,
    String? name,
    String? admin,
    String? email,
    String? plan,
    String? status,
    double? sales,
    DateTime? createdAt,
    String? phone,
  }) {
    return TenantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      admin: admin ?? this.admin,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      sales: sales ?? this.sales,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
    );
  }
}

class PlanModel {
  final String name;
  final double price;
  final String billing;
  final String desc;
  final bool hasKitchen;
  final bool hasStaff;
  final bool hasInventory;

  PlanModel({
    required this.name,
    required this.price,
    required this.billing,
    required this.desc,
    this.hasKitchen = true,
    this.hasStaff = true,
    this.hasInventory = true,
  });
}

class SaaSExpenseModel {
  final String id;
  final String description;
  final double amount;
  final String category; // Server, Domain, Marketing, Support, Other
  final DateTime date;

  SaaSExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });
}

class SuperAdminController extends GetxController {
  final RxList<TenantModel> tenants = <TenantModel>[].obs;
  final RxList<PlanModel> plans = <PlanModel>[].obs;
  final RxList<SaaSExpenseModel> saasExpenses = <SaaSExpenseModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
    loadTenants();
    loadSaaSExpenses();
  }

  Future<void> loadPlans() async {
    final supa = SupabaseService.instance;
    final prefs = await SharedPreferences.getInstance();

    // 1. Load cached plans first
    final cached = prefs.getString('cached_saas_plans');
    if (cached != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cached);
        final List<PlanModel> loaded = decoded.map((item) {
          final String rawDesc = item['desc'] ?? '';
          String cleanDesc = rawDesc;
          bool hasKitchen = item['has_kitchen'] ?? true;
          bool hasStaff = item['has_staff'] ?? true;
          bool hasInventory = item['has_inventory'] ?? true;

          if (rawDesc.contains('|__FEATURES__Detailed:')) {
            final parts = rawDesc.split('|__FEATURES__Detailed:');
            cleanDesc = parts[0].trim();
            try {
              final Map<String, dynamic> feats = jsonDecode(parts[1]);
              hasKitchen = feats['hasKitchen'] ?? true;
              hasStaff = feats['hasStaff'] ?? true;
              hasInventory = feats['hasInventory'] ?? true;
            } catch (e) {
              print('Error decoding cached features: $e');
            }
          }

          return PlanModel(
            name: item['name'],
            price: (item['price'] as num).toDouble(),
            billing: item['billing'],
            desc: cleanDesc,
            hasKitchen: hasKitchen,
            hasStaff: hasStaff,
            hasInventory: hasInventory,
          );
        }).toList();
        plans.assignAll(loaded);
      } catch (e) {
        print('Error decoding cached plans: $e');
      }
    }

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    // 2. Load from Supabase
    try {
      final res = await supa.client.from('subscription_plans').select();
      final List<PlanModel> loaded = [];
      for (final row in res) {
        final String rawDesc = row['description'] ?? '';
        String cleanDesc = rawDesc;
        bool hasKitchen = true;
        bool hasStaff = true;
        bool hasInventory = true;

        if (rawDesc.contains('|__FEATURES__Detailed:')) {
          final parts = rawDesc.split('|__FEATURES__Detailed:');
          cleanDesc = parts[0].trim();
          try {
            final Map<String, dynamic> feats = jsonDecode(parts[1]);
            hasKitchen = feats['hasKitchen'] ?? true;
            hasStaff = feats['hasStaff'] ?? true;
            hasInventory = feats['hasInventory'] ?? true;
          } catch (e) {
            print('Error decoding features from Supabase: $e');
          }
        }

        loaded.add(PlanModel(
          name: row['name'],
          price: (row['price'] as num).toDouble(),
          billing: row['billing'],
          desc: cleanDesc,
          hasKitchen: hasKitchen,
          hasStaff: hasStaff,
          hasInventory: hasInventory,
        ));
      }
      plans.assignAll(loaded);
      
      // Update cache
      await prefs.setString('cached_saas_plans', jsonEncode(loaded.map((p) => {
        'name': p.name,
        'price': p.price,
        'billing': p.billing,
        'desc': p.desc + ' |__FEATURES__Detailed:' + jsonEncode({
          'hasKitchen': p.hasKitchen,
          'hasStaff': p.hasStaff,
          'hasInventory': p.hasInventory,
        }),
      }).toList()));
    } catch (e) {
      print('subscription_plans table not found on Supabase: $e');
    }

    if (plans.isEmpty) {
      plans.assignAll([
        PlanModel(
          name: 'Basic',
          price: 15.0,
          billing: 'Monthly',
          desc: 'Essential features for small cafes and takeaway outlets.',
          hasKitchen: true,
          hasStaff: false,
          hasInventory: false,
        ),
        PlanModel(
          name: 'Standard',
          price: 29.0,
          billing: 'Monthly',
          desc: 'Includes staff management and a kitchen monitor screen.',
          hasKitchen: true,
          hasStaff: true,
          hasInventory: false,
        ),
        PlanModel(
          name: 'Premium',
          price: 49.0,
          billing: 'Monthly',
          desc: 'The complete POS solution with full inventory and ingredient recipe tracking.',
          hasKitchen: true,
          hasStaff: true,
          hasInventory: true,
        ),
      ]);
    }
  }
  Future<void> addPlan({
    required String name,
    required String price,
    required String billing,
    required String desc,
    bool hasKitchen = true,
    bool hasStaff = true,
    bool hasInventory = true,
  }) async {
    final newPlan = PlanModel(
      name: name,
      price: double.tryParse(price) ?? 0.0,
      billing: billing,
      desc: desc,
      hasKitchen: hasKitchen,
      hasStaff: hasStaff,
      hasInventory: hasInventory,
    );
    plans.add(newPlan);

    // Save to cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_saas_plans', jsonEncode(plans.map((p) => {
      'name': p.name,
      'price': p.price,
      'billing': p.billing,
      'desc': p.desc + ' |__FEATURES__Detailed:' + jsonEncode({
        'hasKitchen': p.hasKitchen,
        'hasStaff': p.hasStaff,
        'hasInventory': p.hasInventory,
      }),
    }).toList()));

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      final combinedDescription = desc + ' |__FEATURES__Detailed:' + jsonEncode({
        'hasKitchen': hasKitchen,
        'hasStaff': hasStaff,
        'hasInventory': hasInventory,
      });

      await supa.client.from('subscription_plans').upsert({
        'name': name,
        'price': double.tryParse(price) ?? 0.0,
        'billing': billing,
        'description': combinedDescription,
      });
    } catch (e) {
      print('Error saving plan to Supabase: $e');
    }
  }

  Future<void> deletePlan(String name) async {
    plans.removeWhere((p) => p.name == name);

    // Save to cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_saas_plans', jsonEncode(plans.map((p) => {
      'name': p.name,
      'price': p.price,
      'billing': p.billing,
      'desc': p.desc + ' |__FEATURES__Detailed:' + jsonEncode({
        'hasKitchen': p.hasKitchen,
        'hasStaff': p.hasStaff,
        'hasInventory': p.hasInventory,
      }),
    }).toList()));

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      await supa.client.from('subscription_plans').delete().eq('name', name);
    } catch (e) {
      print('Error deleting plan from Supabase: $e');
    }
  }

  Future<void> updatePlan({
    required String oldName,
    required String name,
    required String price,
    required String billing,
    required String desc,
    bool hasKitchen = true,
    bool hasStaff = true,
    bool hasInventory = true,
  }) async {
    // If the name changed, we delete the old name and insert the new one
    if (oldName != name) {
      plans.removeWhere((p) => p.name == oldName);
      if (!SupabaseService.supabaseUrl.contains('your-project-id')) {
        try {
          final supa = SupabaseService.instance;
          await supa.client.from('subscription_plans').delete().eq('name', oldName);
        } catch (e) {
          print('Error deleting old plan name on update: $e');
        }
      }
    }

    final updatedPlan = PlanModel(
      name: name,
      price: double.tryParse(price) ?? 0.0,
      billing: billing,
      desc: desc,
      hasKitchen: hasKitchen,
      hasStaff: hasStaff,
      hasInventory: hasInventory,
    );

    final existingIndex = plans.indexWhere((p) => p.name == name);
    if (existingIndex >= 0) {
      plans[existingIndex] = updatedPlan;
    } else {
      plans.add(updatedPlan);
    }
    plans.refresh();

    // Save to cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_saas_plans', jsonEncode(plans.map((p) => {
      'name': p.name,
      'price': p.price,
      'billing': p.billing,
      'desc': p.desc + ' |__FEATURES__Detailed:' + jsonEncode({
        'hasKitchen': p.hasKitchen,
        'hasStaff': p.hasStaff,
        'hasInventory': p.hasInventory,
      }),
    }).toList()));

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      final combinedDescription = desc + ' |__FEATURES__Detailed:' + jsonEncode({
        'hasKitchen': hasKitchen,
        'hasStaff': hasStaff,
        'hasInventory': hasInventory,
      });

      await supa.client.from('subscription_plans').upsert({
        'name': name,
        'price': double.tryParse(price) ?? 0.0,
        'billing': billing,
        'description': combinedDescription,
      });
    } catch (e) {
      print('Error updating plan on Supabase: $e');
    }
  }

  Future<void> loadTenants() async {
    isLoading.value = true;
    final supa = SupabaseService.instance;
    
    if (SupabaseService.supabaseUrl.contains('your-project-id')) {
      tenants.assignAll([]);
      isLoading.value = false;
      return;
    }

    try {
      final res = await supa.client
          .from('users')
          .select('*, restaurants(*)')
          .eq('role_id', 2); // admin users

      final List<TenantModel> loaded = [];
      for (final row in res) {
        final rest = row['restaurants'];
        if (rest != null) {
          loaded.add(TenantModel(
            id: rest['id'],
            name: rest['name'],
            admin: row['name'] ?? 'Admin',
            email: row['email'] ?? 'admin@pos.com',
            plan: rest['plan_name'] ?? 'Premium SaaS',
            status: rest['status'] ?? 'Active',
            sales: (rest['gross_sales'] as num?)?.toDouble() ?? 0.00,
            createdAt: DateTime.tryParse(rest['created_at'] ?? '') ?? DateTime.now(),
            phone: rest['receipt_footer'],
          ));
        }
      }
      tenants.assignAll(loaded);
    } catch (e) {
      print('Error loading tenants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSaaSExpenses() async {
    final supa = SupabaseService.instance;
    if (SupabaseService.supabaseUrl.contains('your-project-id')) {
      saasExpenses.assignAll([]);
      return;
    }

    try {
      final res = await supa.client
          .from('saas_expenses')
          .select()
          .order('date', ascending: false);
      
      final List<SaaSExpenseModel> loaded = [];
      for (final row in res) {
        loaded.add(SaaSExpenseModel(
          id: row['id'],
          description: row['description'],
          amount: (row['amount'] as num).toDouble(),
          category: row['category'],
          date: DateTime.parse(row['date']),
        ));
      }
      saasExpenses.assignAll(loaded);
    } catch (e) {
      print('SaaS expenses table not found: $e');
      if (saasExpenses.isEmpty) {
        saasExpenses.assignAll([]);
      }
    }
  }

  Future<String?> addTenant({
    required String name,
    required String admin,
    required String email,
    required String password,
    required String plan,
    required String status,
    String? phone,
  }) async {
    if (SupabaseService.supabaseUrl.contains('your-project-id')) {
      final restId = const Uuid().v4();
      final newTenant = TenantModel(
        id: restId,
        name: name,
        admin: admin,
        email: email,
        plan: plan,
        status: status,
        sales: 0.00,
        createdAt: DateTime.now(),
        phone: phone,
      );
      tenants.insert(0, newTenant);
      return null;
    }

    try {
      final supa = SupabaseService.instance;

      // 1. Sign up the user in Supabase Auth so they have a valid login credentials
      String? actualUserId;
      try {
        final authRes = await supa.client.auth.signUp(
          email: email.trim().toLowerCase(),
          password: password,
        );
        actualUserId = authRes.user?.id;
      } catch (authError) {
        return 'Auth registration failed: ${authError.toString()}';
      }

      if (actualUserId == null) {
        return 'Auth registration failed: User account could not be created.';
      }

      final restId = const Uuid().v4();

      // 2. Insert restaurant
      await supa.client.from('restaurants').insert({
        'id': restId,
        'name': name,
        'currency': 'PKR',
        'currency_symbol': 'Rs. ',
        'tax_percentage': 18.0,
        'plan_name': plan,
        'status': status,
        'kitchen_bypass': false,
        'receipt_footer': phone,
      });

      // 3. Insert admin profile in database using actualUserId
      await supa.client.from('users').upsert({
        'id': actualUserId,
        'name': admin,
        'email': email.trim().toLowerCase(),
        'role_id': 2, // Admin
        'restaurant_id': restId,
      });

      // Add tenant to UI list dynamically for immediate response
      final newTenant = TenantModel(
        id: restId,
        name: name,
        admin: admin,
        email: email,
        plan: plan,
        status: status,
        sales: 0.00,
        createdAt: DateTime.now(),
        phone: phone,
      );
      tenants.insert(0, newTenant);
      
      loadTenants();
      return null;
    } catch (e) {
      return 'Database error: ${e.toString()}';
    }
  }

  Future<void> updateSubscription(String restaurantId, {required String status, String? plan, String? phone}) async {
    tenants.value = tenants.map((t) {
      if (t.id == restaurantId) {
        return t.copyWith(
          status: status,
          plan: plan ?? t.plan,
          phone: phone ?? t.phone,
        );
      }
      return t;
    }).toList();

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      final Map<String, dynamic> updateData = {'status': status};
      if (plan != null) {
        updateData['plan_name'] = plan;
      }
      if (phone != null) {
        updateData['receipt_footer'] = phone;
      }
      await supa.client
          .from('restaurants')
          .update(updateData)
          .eq('id', restaurantId);
    } catch (e) {
      print('Error updating subscription: $e');
    }
  }

  Future<void> deleteTenant(String restaurantId) async {
    // Remove from local list first
    tenants.removeWhere((t) => t.id == restaurantId);
    tenants.refresh();

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      
      // Delete order items
      try {
        final ordersRes = await supa.client.from('orders').select('id').eq('restaurant_id', restaurantId);
        if (ordersRes != null) {
          final List orderIds = (ordersRes as List).map((o) => o['id']).toList();
          if (orderIds.isNotEmpty) {
            await supa.client.from('order_items').delete().inFilter('order_id', orderIds);
          }
        }
      } catch (_) {}

      // Delete orders
      try {
        await supa.client.from('orders').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete deal items & ingredients
      try {
        final itemsRes = await supa.client.from('menu_items').select('id').eq('restaurant_id', restaurantId);
        if (itemsRes != null) {
          final List itemIds = (itemsRes as List).map((i) => i['id']).toList();
          if (itemIds.isNotEmpty) {
            await supa.client.from('deal_items').delete().inFilter('deal_item_id', itemIds);
            await supa.client.from('menu_item_ingredients').delete().inFilter('menu_item_id', itemIds);
          }
        }
      } catch (_) {}

      // Delete tables
      try {
        await supa.client.from('tables').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete menu items
      try {
        await supa.client.from('menu_items').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete categories
      try {
        await supa.client.from('menu_categories').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete ingredients
      try {
        await supa.client.from('ingredients').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete users
      try {
        await supa.client.from('users').delete().eq('restaurant_id', restaurantId);
      } catch (_) {}

      // Delete restaurant itself
      await supa.client.from('restaurants').delete().eq('id', restaurantId);
    } catch (e) {
      print('Error deleting tenant: $e');
    }
  }

  Future<void> addSaaSExpense({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    final expId = const Uuid().v4();
    final newExp = SaaSExpenseModel(
      id: expId,
      description: description,
      amount: amount,
      category: category,
      date: date,
    );
    saasExpenses.insert(0, newExp);

    if (SupabaseService.supabaseUrl.contains('your-project-id')) return;

    try {
      final supa = SupabaseService.instance;
      await supa.client.from('saas_expenses').insert({
        'id': expId,
        'description': description,
        'amount': amount,
        'category': category,
        'date': date.toUtc().toIso8601String(),
      });
    } catch (e) {
      print('Error saving SaaS expense: $e');
    }
  }

  // Getters for metrics
  double get mrr => tenants.where((t) => t.status == 'Active' || t.status == 'Trial').fold(0.0, (sum, tenant) {
    final planPrice = plans.firstWhere(
      (p) => p.name.toLowerCase().contains(tenant.plan.toLowerCase()),
      orElse: () => PlanModel(name: '', price: 0.0, billing: '', desc: ''),
    ).price;
    return sum + planPrice;
  });

  int get activeCount => tenants.where((t) => t.status == 'Active').length;
  int get expiringCount => tenants.where((t) => t.status == 'Trial').length;

  double get totalExpenses => saasExpenses.fold(0.0, (sum, item) => sum + item.amount);
  double get netProfit => mrr - totalExpenses;
}

// Global accessor
SuperAdminController get superAdminProvider => Get.find<SuperAdminController>();
