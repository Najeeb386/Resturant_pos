import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/core/supabase/supabase_client.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';

class SyncManager {
  final AppDatabase db;
  final Connectivity _connectivity = Connectivity();
  bool _isSyncing = false;
  bool _isDownloading = false;
  Timer? _syncTimer;

  SyncManager(this.db) {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        syncQueue();
      }
    });
  }

  void startPeriodicSync(String restaurantId) {
    _syncTimer?.cancel();
    // Run sync manager updates immediately in background
    syncQueue();
    downloadUpdatesFromServer(restaurantId);
    
    // Periodically run every 10 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await syncQueue();
      await downloadUpdatesFromServer(restaurantId);
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Queue an action locally
  Future<void> queueAction({
    required String actionType, // INSERT, UPDATE, DELETE
    required String tableName,
    required String recordId,
    required Map<String, dynamic> payload,
  }) async {
    await db.into(db.offlineQueues).insert(
      OfflineQueuesCompanion.insert(
        actionType: actionType,
        tableTarget: tableName,
        recordId: recordId,
        payload: jsonEncode(payload),
      ),
    );
    
    // Unconditionally sync immediately on save, escaping transaction zone if any
    Timer.run(() {
      syncQueue();
    });
  }

  // Process the queue and send to Supabase
  Future<void> syncQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = await (db.select(db.offlineQueues)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

      if (queue.isEmpty) {
        _isSyncing = false;
        return;
      }

      print('Starting sync of ${queue.length} items in the queue...');

      for (final item in queue) {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        bool success = false;

        try {
          // Perform appropriate Supabase operation based on table and action
          final supa = SupabaseService.instance;
          
          if (item.actionType == 'INSERT') {
            await supa.client.from(item.tableTarget).upsert(payload);
            success = true;
          } else if (item.actionType == 'UPDATE') {
            await supa.client.from(item.tableTarget).update(payload).eq('id', item.recordId);
            success = true;
          } else if (item.actionType == 'DELETE') {
            if (item.tableTarget == 'deal_items') {
              await supa.client.from(item.tableTarget).delete().eq('deal_item_id', item.recordId);
            } else {
              await supa.client.from(item.tableTarget).delete().eq('id', item.recordId);
            }
            success = true;
          }
        } catch (e) {
          print('Sync error for item ${item.id} on table ${item.tableTarget}: $e');
          // If it is a network error, stop processing queue. If database error, skip item (or handle otherwise)
          if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
            break;
          }
          // Skip corrupt records to prevent getting stuck
          success = true; 
        }

        if (success) {
          await (db.delete(db.offlineQueues)..where((t) => t.id.equals(item.id))).go();
        }
      }
    } catch (e) {
      print('Sync queue process failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Fetch full update from Supabase to local DB
  // Fetch full update from Supabase to local DB
  Future<void> downloadUpdatesFromServer(String restaurantId) async {
    if (_isDownloading) return;
    _isDownloading = true;

    final supa = SupabaseService.instance;
    if (!supa.isAuthenticated) {
      _isDownloading = false;
      return;
    }

    try {
      // 1. Fetch restaurant status and details to verify if active
      final restData = await supa.client
          .from('restaurants')
          .select()
          .eq('id', restaurantId)
          .maybeSingle();

      if (restData != null) {
        final status = restData['status'] ?? 'Active';
        final auth = authProvider;
        final user = auth.state.value.user;
        if (user != null && user.roleId != 1 && status != 'Active' && status != 'Trial') {
          // Immediately trigger suspended user logout and redirection
          _isDownloading = false;
          auth.handleSuspendedRestaurant();
          return;
        }

        // Determine plan-based feature gates
        final planName = restData['plan'] ?? 'Basic';
        final bool hasKitchen = planName.toLowerCase() != 'basic';
        final bool hasStaff = planName.toLowerCase() != 'basic';
        final bool hasInventory = planName.toLowerCase() == 'premium';

        final dbRest = LocalRestaurant(
          id: restaurantId,
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

        // Update local SQLite DB
        await db.into(db.localRestaurants).insertOnConflictUpdate(dbRest);

        // Update AuthController cached session in-memory and in SharedPreferences
        if (auth.state.value.restaurant != null && auth.state.value.restaurant!.id == restaurantId) {
          await auth.updateLocalCachedSession(dbRest);
        }
      }
      // Sync Ingredients first (so menu items mapping works)
      final ingredients = await supa.client.from('ingredients').select().eq('restaurant_id', restaurantId);
      final ingredientIds = ingredients.map((i) => i['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localIngredients)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(ingredientIds))).go();
        for (final ing in ingredients) {
          await db.into(db.localIngredients).insertOnConflictUpdate(
            LocalIngredientsCompanion.insert(
              id: ing['id'],
              restaurantId: ing['restaurant_id'],
              name: ing['name'],
              quantity: (ing['quantity'] as num).toDouble(),
              unit: ing['unit'],
            ),
          );
        }
      });

      // 1. Sync Categories
      final cats = await supa.client.from('menu_categories').select().eq('restaurant_id', restaurantId);
      final catIds = cats.map((c) => c['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localMenuCategories)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(catIds))).go();
        for (final cat in cats) {
          await db.into(db.localMenuCategories).insertOnConflictUpdate(
            LocalMenuCategoriesCompanion.insert(
              id: cat['id'],
              restaurantId: cat['restaurant_id'],
              name: cat['name'],
            ),
          );
        }
      });

      // 2. Sync Menu Items
      final items = await supa.client.from('menu_items').select().eq('restaurant_id', restaurantId);
      final itemIds = items.map((i) => i['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localMenuItems)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(itemIds))).go();
        for (final item in items) {
          await db.into(db.localMenuItems).insertOnConflictUpdate(
            LocalMenuItemsCompanion.insert(
              id: item['id'],
              restaurantId: item['restaurant_id'],
              categoryId: item['category_id'],
              name: item['name'],
              description: Value(item['description']),
              price: (item['price'] as num).toDouble(),
              costPrice: Value((item['cost_price'] as num?)?.toDouble() ?? 0.0),
              stockQuantity: Value(item['stock_quantity'] ?? 0),
              imageUrl: Value(item['image_url']),
              isDeal: Value(item['is_deal'] ?? false),
            ),
          );
        }
      });

      // Sync MenuItemIngredients (recipes) & DealItems (deals) using menu item IDs
      if (itemIds.isNotEmpty) {
        final recipes = await supa.client.from('menu_item_ingredients').select().inFilter('menu_item_id', itemIds);
        await db.transaction(() async {
          await (db.delete(db.localMenuItemIngredients)..where((t) => t.menuItemId.isIn(itemIds))).go();
          for (final r in recipes) {
            await db.into(db.localMenuItemIngredients).insertOnConflictUpdate(
              LocalMenuItemIngredientsCompanion.insert(
                menuItemId: r['menu_item_id'],
                ingredientId: r['ingredient_id'],
                quantityNeeded: (r['quantity_needed'] as num).toDouble(),
              ),
            );
          }
        });

        final deals = await supa.client.from('deal_items').select().inFilter('deal_item_id', itemIds);
        await db.transaction(() async {
          await (db.delete(db.localDealItems)..where((t) => t.dealItemId.isIn(itemIds))).go();
          for (final dItem in deals) {
            await db.into(db.localDealItems).insertOnConflictUpdate(
              LocalDealItemsCompanion.insert(
                dealItemId: dItem['deal_item_id'],
                childItemId: dItem['child_item_id'],
                quantity: Value(dItem['quantity'] as int),
              ),
            );
          }
        });
      }

      // 3. Sync Tables
      final tables = await supa.client.from('tables').select().eq('restaurant_id', restaurantId);
      final tableIds = tables.map((t) => t['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localTables)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(tableIds))).go();
        for (final table in tables) {
          await db.into(db.localTables).insertOnConflictUpdate(
            LocalTablesCompanion.insert(
              id: table['id'],
              restaurantId: table['restaurant_id'],
              tableNumber: table['table_number'],
              capacity: Value(table['capacity'] ?? 4),
              status: Value(table['status'] ?? 'available'),
            ),
          );
        }
      });

      // 4. Sync Orders (fetch last 100 orders)
      final orders = await supa.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false)
          .limit(100);

      await db.transaction(() async {
        for (final order in orders) {
          await db.into(db.localOrders).insertOnConflictUpdate(
            LocalOrdersCompanion.insert(
              id: order['id'],
              restaurantId: order['restaurant_id'],
              tableId: Value(order['table_id']),
              userId: order['user_id'],
              orderType: order['order_type'],
              status: order['status'],
              paymentStatus: order['payment_status'],
              paymentMethod: Value(order['payment_method']),
              subtotal: (order['subtotal'] as num).toDouble(),
              tax: (order['tax'] as num).toDouble(),
              discount: Value((order['discount'] as num?)?.toDouble() ?? 0.0),
              deliveryFee: Value((order['delivery_fee'] as num?)?.toDouble() ?? 0.0),
              total: (order['total'] as num).toDouble(),
              customerName: Value(order['customer_name']),
              customerPhone: Value(order['customer_phone']),
              deliveryAddress: Value(order['delivery_address']),
              notes: Value(order['notes']),
              createdAt: DateTime.parse(order['created_at']).toLocal(),
              billNumber: Value(order['bill_number']),
            ),
          );

          // Sync order items
          final itemsList = order['order_items'] as List<dynamic>;
          for (final item in itemsList) {
            await db.into(db.localOrderItems).insertOnConflictUpdate(
              LocalOrderItemsCompanion.insert(
                id: item['id'],
                orderId: item['order_id'],
                menuItemId: item['menu_item_id'],
                quantity: item['quantity'],
                price: (item['price'] as num).toDouble(),
                costPrice: Value((item['cost_price'] as num?)?.toDouble() ?? 0.0),
              ),
            );
          }
        }
      });

      // 5. Sync Users list
      final users = await supa.client.from('users').select().eq('restaurant_id', restaurantId);
      final userIds = users.map((u) => u['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localUsers)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(userIds))).go();
        for (final user in users) {
          await db.into(db.localUsers).insertOnConflictUpdate(
            LocalUser(
              id: user['id'],
              name: user['name'],
              email: user['email'],
              roleId: user['role_id'],
              restaurantId: user['restaurant_id'],
            ),
          );
        }
      });

      // 6. Sync Expenses list
      final exps = await supa.client.from('expenses').select().eq('restaurant_id', restaurantId);
      final expIds = exps.map((e) => e['id'] as String).toList();
      await db.transaction(() async {
        await (db.delete(db.localExpenses)..where((t) => t.restaurantId.equals(restaurantId) & t.id.isNotIn(expIds))).go();
        for (final exp in exps) {
          await db.into(db.localExpenses).insertOnConflictUpdate(
            LocalExpensesCompanion.insert(
              id: exp['id'],
              restaurantId: exp['restaurant_id'],
              name: exp['title'] ?? exp['name'] ?? '',
              amount: (exp['amount'] as num).toDouble(),
              category: exp['category'],
              date: DateTime.parse(exp['date']).toLocal(),
            ),
          );
        }
      });

    } catch (e) {
      print('Downloading updates from server failed: $e');
    } finally {
      _isDownloading = false;
    }
  }
}
