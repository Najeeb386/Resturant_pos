import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/connection/connection_interface.dart';

part 'local_database.g.dart';

// Tables

class LocalRestaurants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get currencySymbol => text().withDefault(const Constant('\$'))();
  RealColumn get taxPercentage => real().withDefault(const Constant(0.0))();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get receiptHeader => text().nullable()();
  TextColumn get receiptFooter => text().nullable()();
  BoolColumn get kitchenBypass => boolean().withDefault(const Constant(false))();
  TextColumn get paymentMethods => text().withDefault(const Constant('Cash,Card'))();
  TextColumn get planName => text().nullable()();
  BoolColumn get hasKitchen => boolean().withDefault(const Constant(true))();
  BoolColumn get hasStaff => boolean().withDefault(const Constant(true))();
  BoolColumn get hasInventory => boolean().withDefault(const Constant(true))();
  IntColumn get startingBillNumber => integer().withDefault(const Constant(1000))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn get roleId => integer()(); // 1 = SuperAdmin, 2 = RestaurantAdmin, 3 = Cashier, 4 = KitchenStaff, 5 = Waiter
  TextColumn get restaurantId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalTables extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get tableNumber => text()();
  IntColumn get capacity => integer().withDefault(const Constant(4))();
  TextColumn get status => text().withDefault(const Constant('available'))(); // available, occupied, cleaning

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMenuCategories extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  TextColumn get imageUrl => text().nullable()();
  BoolColumn get isDeal => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()(); // kg, g, l, ml, pcs, etc.

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMenuItemIngredients extends Table {
  TextColumn get menuItemId => text()();
  TextColumn get ingredientId => text()();
  RealColumn get quantityNeeded => real()();

  @override
  Set<Column> get primaryKey => {menuItemId, ingredientId};
}

class LocalDealItems extends Table {
  TextColumn get dealItemId => text()(); // The main MenuItem id representing the deal
  TextColumn get childItemId => text()(); // The menu item included in the deal
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {dealItemId, childItemId};
}

class LocalOrders extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get orderType => text()(); // dine_in, takeaway, delivery
  TextColumn get status => text()(); // draft, pending, preparing, ready, served, completed, cancelled
  TextColumn get paymentStatus => text()(); // paid, unpaid
  TextColumn get paymentMethod => text().nullable()(); // Cash, Card, COD, etc.
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get deliveryFee => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get deliveryAddress => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get billNumber => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalOrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get menuItemId => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalInventoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get restaurantId => text()();
  TextColumn get itemName => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get cost => real()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OfflineQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()(); // INSERT, UPDATE, DELETE
  TextColumn get tableTarget => text()();
  TextColumn get recordId => text()();
  TextColumn get payload => text()(); // JSON string representation of data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Database Class

@DriftDatabase(tables: [
  LocalRestaurants,
  LocalUsers,
  LocalTables,
  LocalMenuCategories,
  LocalMenuItems,
  LocalIngredients,
  LocalMenuItemIngredients,
  LocalDealItems,
  LocalOrders,
  LocalOrderItems,
  LocalExpenses,
  LocalInventoryLogs,
  OfflineQueues,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          await _ensureNewColumns();
        },
        beforeOpen: (details) async {
          // Always ensure new columns exist, regardless of migration state
          await _ensureNewColumns();
        },
      );

  Future<void> _ensureNewColumns() async {
    try {
      await customStatement(
        'ALTER TABLE local_restaurants ADD COLUMN starting_bill_number INTEGER NOT NULL DEFAULT 1000;',
      );
    } catch (_) {
      // Column already exists — safe to ignore
    }
    try {
      await customStatement(
        'ALTER TABLE local_orders ADD COLUMN bill_number INTEGER;',
      );
    } catch (_) {
      // Column already exists — safe to ignore
    }
  }

  // Clear Database on Logout
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
