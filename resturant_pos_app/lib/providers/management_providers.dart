import 'dart:async';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';

class ManagementController extends GetxController {
  final RxList<LocalTable> tables = <LocalTable>[].obs;
  final RxList<LocalMenuCategory> categories = <LocalMenuCategory>[].obs;
  final RxList<LocalMenuItem> menuItems = <LocalMenuItem>[].obs;
  final RxList<LocalExpense> expenses = <LocalExpense>[].obs;
  final RxList<LocalIngredient> ingredients = <LocalIngredient>[].obs;
  final RxList<LocalInventoryLog> inventoryLogs = <LocalInventoryLog>[].obs;
  final RxList<LocalUser> staff = <LocalUser>[].obs;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    bindStreams();
  }

  void bindStreams() {
    final db = databaseProvider;
    final auth = authProvider.state.value;

    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();

    if (auth.restaurant == null) {
      tables.clear();
      categories.clear();
      menuItems.clear();
      expenses.clear();
      ingredients.clear();
      inventoryLogs.clear();
      staff.clear();
      return;
    }

    final restaurantId = auth.restaurant!.id;

    // 1. Tables Stream
    _subscriptions.add(
      (db.select(db.localTables)..where((t) => t.restaurantId.equals(restaurantId)))
          .watch()
          .listen((data) => tables.assignAll(data))
    );

    // 2. Categories Stream
    _subscriptions.add(
      (db.select(db.localMenuCategories)..where((t) => t.restaurantId.equals(restaurantId)))
          .watch()
          .listen((data) => categories.assignAll(data))
    );

    // 3. Menu Items Stream
    _subscriptions.add(
      (db.select(db.localMenuItems)..where((t) => t.restaurantId.equals(restaurantId)))
          .watch()
          .listen((data) => menuItems.assignAll(data))
    );

    // 4. Expenses Stream
    _subscriptions.add(
      (db.select(db.localExpenses)
            ..where((t) => t.restaurantId.equals(restaurantId))
            ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
          .watch()
          .listen((data) => expenses.assignAll(data))
    );

    // 5. Ingredients Stream
    _subscriptions.add(
      (db.select(db.localIngredients)..where((t) => t.restaurantId.equals(restaurantId)))
          .watch()
          .listen((data) => ingredients.assignAll(data))
    );

    // 6. Inventory Logs Stream
    _subscriptions.add(
      (db.select(db.localInventoryLogs)
            ..where((t) => t.restaurantId.equals(restaurantId))
            ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
          .watch()
          .listen((data) => inventoryLogs.assignAll(data))
    );

    // 7. Staff Stream
    _subscriptions.add(
      (db.select(db.localUsers)..where((t) => t.restaurantId.equals(restaurantId)))
          .watch()
          .listen((data) => staff.assignAll(data))
    );
  }

  void reloadStreams() {
    bindStreams();
  }

  @override
  void onClose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.onClose();
  }

  // --- TABLES CRUD ---
  Future<void> addTable(String number, int capacity) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final id = const Uuid().v4();
    final companion = LocalTablesCompanion.insert(
      id: id,
      restaurantId: auth.restaurant!.id,
      tableNumber: number,
      capacity: d.Value(capacity),
      status: const d.Value('available'),
    );

    await db.into(db.localTables).insert(companion);

    // Sync
    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'tables',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'table_number': number,
        'capacity': capacity,
        'status': 'available',
      },
    );
  }

  Future<void> deleteTable(String id) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // Optimistic UI update
    tables.removeWhere((t) => t.id == id);

    await (db.delete(db.localTables)..where((t) => t.id.equals(id))).go();

    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'tables',
      recordId: id,
      payload: {},
    );
  }

  // --- CATEGORIES CRUD ---
  Future<void> addCategory(String name) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final id = const Uuid().v4();
    await db.into(db.localMenuCategories).insert(
      LocalMenuCategoriesCompanion.insert(
        id: id,
        restaurantId: auth.restaurant!.id,
        name: name,
      ),
    );

    // Optimistic UI update
    categories.add(LocalMenuCategory(
      id: id,
      restaurantId: auth.restaurant!.id,
      name: name,
    ));

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'menu_categories',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'name': name,
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // Optimistic UI update
    categories.removeWhere((c) => c.id == id);
    menuItems.removeWhere((item) => item.categoryId == id);

    await (db.delete(db.localMenuCategories)..where((t) => t.id.equals(id))).go();

    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'menu_categories',
      recordId: id,
      payload: {},
    );
  }

  // --- MENU ITEMS CRUD ---
  Future<String> addMenuItem({
    required String name,
    required String categoryId,
    required double price,
    required double costPrice,
    required int stock,
    String? description,
    String? imageUrl,
    bool isDeal = false,
  }) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return '';

    final id = const Uuid().v4();
    await db.into(db.localMenuItems).insert(
      LocalMenuItemsCompanion.insert(
        id: id,
        restaurantId: auth.restaurant!.id,
        categoryId: categoryId,
        name: name,
        description: d.Value(description),
        imageUrl: d.Value(imageUrl),
        price: price,
        costPrice: d.Value(costPrice),
        stockQuantity: d.Value(stock),
        isDeal: d.Value(isDeal),
      ),
    );

    // Optimistic UI update
    menuItems.add(LocalMenuItem(
      id: id,
      restaurantId: auth.restaurant!.id,
      categoryId: categoryId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      costPrice: costPrice,
      stockQuantity: stock,
      isDeal: isDeal,
    ));

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'menu_items',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'price': price,
        'cost_price': costPrice,
        'stock_quantity': stock,
        'is_deal': isDeal,
      },
    );
    return id;
  }

  Future<void> deleteMenuItem(String id) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // Optimistic UI update
    menuItems.removeWhere((item) => item.id == id);

    await (db.delete(db.localMenuItems)..where((t) => t.id.equals(id))).go();

    // If it is a deal, delete from local_deal_items and queue deal_items delete
    await (db.delete(db.localDealItems)..where((t) => t.dealItemId.equals(id))).go();
    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'deal_items',
      recordId: id,
      payload: {},
    );

    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'menu_items',
      recordId: id,
      payload: {},
    );
  }

  Future<List<LocalDealItem>> getDealItems(String dealId) async {
    final db = databaseProvider;
    return await (db.select(db.localDealItems)..where((t) => t.dealItemId.equals(dealId))).get();
  }

  Future<void> saveDealItems(String dealId, List<Map<String, dynamic>> items) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // 1. Delete existing local deal items
    await (db.delete(db.localDealItems)..where((t) => t.dealItemId.equals(dealId))).go();

    // 2. Queue delete action on Supabase (cleans up any old records)
    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'deal_items',
      recordId: dealId,
      payload: {},
    );

    // 3. Insert and queue new items
    for (final item in items) {
      final childId = item['childItemId'] as String;
      final qty = item['quantity'] as int;

      await db.into(db.localDealItems).insertOnConflictUpdate(
        LocalDealItemsCompanion.insert(
          dealItemId: dealId,
          childItemId: childId,
          quantity: d.Value(qty),
        ),
      );

      await sync.queueAction(
        actionType: 'INSERT',
        tableName: 'deal_items',
        recordId: '${dealId}_$childId',
        payload: {
          'deal_item_id': dealId,
          'child_item_id': childId,
          'quantity': qty,
        },
      );
    }
  }

  Future<void> updateCategory(String id, String newName) async {
    try {
      final db = databaseProvider;
      final sync = syncManagerProvider;

      print('SyncQueue: Updating category in local DB: $id to "$newName"');
      await (db.update(db.localMenuCategories)..where((t) => t.id.equals(id))).write(
        LocalMenuCategoriesCompanion(
          name: d.Value(newName),
        ),
      );

      // Optimistic UI update
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = LocalMenuCategory(
          id: id,
          restaurantId: categories[index].restaurantId,
          name: newName,
        );
        categories.refresh(); // Force GetX to refresh the Obx list immediately
      }

      await sync.queueAction(
        actionType: 'UPDATE',
        tableName: 'menu_categories',
        recordId: id,
        payload: {
          'id': id,
          'name': newName,
        },
      );
    } catch (e, stack) {
      print('SyncQueue ERROR: Failed to update category: $e');
      print(stack);
    }
  }

  Future<void> updateMenuItem({
    required String id,
    required String name,
    required String categoryId,
    required double price,
    required double costPrice,
    required int stock,
    String? imageUrl,
    bool? isDeal,
  }) async {
    try {
      final db = databaseProvider;
      final sync = syncManagerProvider;

      print('SyncQueue: Updating menu item in local DB: $id to "$name"');
      await (db.update(db.localMenuItems)..where((t) => t.id.equals(id))).write(
        LocalMenuItemsCompanion(
          name: d.Value(name),
          categoryId: d.Value(categoryId),
          price: d.Value(price),
          costPrice: d.Value(costPrice),
          stockQuantity: d.Value(stock),
          imageUrl: d.Value(imageUrl),
          isDeal: isDeal != null ? d.Value(isDeal) : const d.Value.absent(),
        ),
      );

      // Optimistic UI update
      final index = menuItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        menuItems[index] = LocalMenuItem(
          id: id,
          restaurantId: menuItems[index].restaurantId,
          categoryId: categoryId,
          name: name,
          description: menuItems[index].description,
          imageUrl: imageUrl,
          price: price,
          costPrice: costPrice,
          stockQuantity: stock,
          isDeal: isDeal ?? menuItems[index].isDeal,
        );
        menuItems.refresh(); // Force GetX to refresh the Obx list immediately
      }

      await sync.queueAction(
        actionType: 'UPDATE',
        tableName: 'menu_items',
        recordId: id,
        payload: {
          'id': id,
          'category_id': categoryId,
          'name': name,
          'image_url': imageUrl,
          'price': price,
          'cost_price': costPrice,
          'stock_quantity': stock,
          if (isDeal != null) 'is_deal': isDeal,
        },
      );
    } catch (e, stack) {
      print('SyncQueue ERROR: Failed to update menu item: $e');
      print(stack);
    }
  }

  // --- EXPENSES CRUD ---
  Future<void> addExpense(String name, double amount, String category, DateTime date, String? notes) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final id = const Uuid().v4();
    await db.into(db.localExpenses).insert(
      LocalExpensesCompanion.insert(
        id: id,
        restaurantId: auth.restaurant!.id,
        name: name,
        amount: amount,
        category: category,
        date: date,
        notes: d.Value(notes),
      ),
    );

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'expenses',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'name': name,
        'amount': amount,
        'category': category,
        'date': date.toUtc().toIso8601String(),
        'notes': notes,
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    await (db.delete(db.localExpenses)..where((t) => t.id.equals(id))).go();

    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'expenses',
      recordId: id,
      payload: {},
    );
  }

  // --- INVENTORY CRUD ---
  Future<void> addIngredient(String name, double initialQty, String unit) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final id = const Uuid().v4();
    await db.into(db.localIngredients).insert(
      LocalIngredientsCompanion.insert(
        id: id,
        restaurantId: auth.restaurant!.id,
        name: name,
        quantity: initialQty,
        unit: unit,
      ),
    );

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'ingredients',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'name': name,
        'quantity': initialQty,
        'unit': unit,
      },
    );
  }

  Future<void> restockIngredient({
    required String ingredientId,
    required double qtyToAdd,
    required double cost,
  }) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final ingredient = await (db.select(db.localIngredients)..where((t) => t.id.equals(ingredientId))).getSingleOrNull();
    if (ingredient == null) return;

    final newQty = ingredient.quantity + qtyToAdd;
    final logId = const Uuid().v4();
    final expenseId = const Uuid().v4();

    await db.transaction(() async {
      await (db.update(db.localIngredients)..where((t) => t.id.equals(ingredientId)))
          .write(LocalIngredientsCompanion(quantity: d.Value(newQty)));

      await db.into(db.localInventoryLogs).insert(
        LocalInventoryLogsCompanion.insert(
          id: logId,
          restaurantId: auth.restaurant!.id,
          itemName: ingredient.name,
          quantity: qtyToAdd,
          unit: ingredient.unit,
          cost: cost,
          date: DateTime.now(),
        ),
      );

      await db.into(db.localExpenses).insert(
        LocalExpensesCompanion.insert(
          id: expenseId,
          restaurantId: auth.restaurant!.id,
          name: 'Procurement: Restock ${ingredient.name} ($qtyToAdd ${ingredient.unit})',
          amount: cost,
          category: 'Procurement',
          date: DateTime.now(),
        ),
      );
    });

    await sync.queueAction(
      actionType: 'UPDATE',
      tableName: 'ingredients',
      recordId: ingredientId,
      payload: {'quantity': newQty},
    );

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'inventory_logs',
      recordId: logId,
      payload: {
        'id': logId,
        'restaurant_id': auth.restaurant!.id,
        'item_name': ingredient.name,
        'quantity': qtyToAdd,
        'unit': ingredient.unit,
        'cost': cost,
        'date': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'expenses',
      recordId: expenseId,
      payload: {
        'id': expenseId,
        'restaurant_id': auth.restaurant!.id,
        'name': 'Procurement: Restock ${ingredient.name} ($qtyToAdd ${ingredient.unit})',
        'amount': cost,
        'category': 'Procurement',
        'date': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  // --- STAFF CRUD ---
  Future<void> addStaff({required String name, required String email, required int roleId}) async {
    final db = databaseProvider;
    final auth = authProvider.state.value;
    final sync = syncManagerProvider;
    if (auth.restaurant == null) return;

    final id = const Uuid().v4();
    final companion = LocalUsersCompanion.insert(
      id: id,
      restaurantId: d.Value(auth.restaurant!.id),
      name: name,
      email: email,
      roleId: roleId,
    );

    await db.into(db.localUsers).insert(companion);

    // Sync
    await sync.queueAction(
      actionType: 'INSERT',
      tableName: 'users',
      recordId: id,
      payload: {
        'id': id,
        'restaurant_id': auth.restaurant!.id,
        'name': name,
        'email': email,
        'role_id': roleId,
      },
    );
  }

  Future<void> deleteStaff(String id) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    await (db.delete(db.localUsers)..where((t) => t.id.equals(id))).go();

    await sync.queueAction(
      actionType: 'DELETE',
      tableName: 'users',
      recordId: id,
      payload: {},
    );
  }
}

// Global accessors for backward compatibility
ManagementController get tablesManagerProvider => Get.find<ManagementController>();
ManagementController get menuManagerProvider => Get.find<ManagementController>();
ManagementController get expensesManagerProvider => Get.find<ManagementController>();
ManagementController get inventoryManagerProvider => Get.find<ManagementController>();
ManagementController get staffManagerProvider => Get.find<ManagementController>();
