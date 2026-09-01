import 'dart:async';
import 'package:get/get.dart' hide Value;
import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';

class OrderWithDetails {
  final LocalOrder order;
  final LocalTable? table;
  final List<OrderItemWithMenu> items;

  OrderWithDetails({
    required this.order,
    this.table,
    required this.items,
  });
}

class OrderItemWithMenu {
  final LocalOrderItem orderItem;
  final LocalMenuItem? menuItem;

  OrderItemWithMenu({
    required this.orderItem,
    this.menuItem,
  });
}

class OrdersController extends GetxController {
  final RxList<OrderWithDetails> orders = <OrderWithDetails>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    // Bind the order streams immediately
    bindStream();
  }

  void bindStream() {
    final db = databaseProvider;
    final auth = authProvider.state.value;

    if (auth.restaurant == null) {
      orders.clear();
      return;
    }

    final restaurantId = auth.restaurant!.id;

    final query = db.select(db.localOrders).join([
      leftOuterJoin(db.localOrderItems, db.localOrderItems.orderId.equalsExp(db.localOrders.id)),
    ])
    ..where(db.localOrders.restaurantId.equals(restaurantId))
    ..orderBy([OrderingTerm(expression: db.localOrders.createdAt, mode: OrderingMode.desc)]);

    _subscription?.cancel();
    _subscription = query.watch().asyncMap((rows) async {
      // Group rows by order ID
      final Map<String, LocalOrder> ordersMap = {};
      final Map<String, List<LocalOrderItem>> orderItemsMap = {};

      for (final row in rows) {
        final order = row.readTable(db.localOrders);
        final item = row.readTableOrNull(db.localOrderItems);

        ordersMap[order.id] = order;
        if (item != null) {
          orderItemsMap.putIfAbsent(order.id, () => []).add(item);
        }
      }

      final List<OrderWithDetails> results = [];
      for (final order in ordersMap.values) {
        // Get table details
        LocalTable? table;
        if (order.tableId != null) {
          table = await (db.select(db.localTables)..where((t) => t.id.equals(order.tableId!))).getSingleOrNull();
        }

        final oItems = orderItemsMap[order.id] ?? [];
        final List<OrderItemWithMenu> itemsWithMenu = [];
        for (final oItem in oItems) {
          final mItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oItem.menuItemId))).getSingleOrNull();
          itemsWithMenu.add(OrderItemWithMenu(orderItem: oItem, menuItem: mItem));
        }

        results.add(OrderWithDetails(order: order, table: table, items: itemsWithMenu));
      }

      // Sort results by createdAt desc since map grouping might lose order
      results.sort((a, b) => b.order.createdAt.compareTo(a.order.createdAt));
      return results;
    }).listen((data) {
      orders.assignAll(data);
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    await (db.update(db.localOrders)..where((t) => t.id.equals(orderId)))
        .write(LocalOrdersCompanion(status: Value(newStatus)));

    // Queue sync action
    await sync.queueAction(
      actionType: 'UPDATE',
      tableName: 'orders',
      recordId: orderId,
      payload: {'status': newStatus},
    );
  }

  Future<void> updatePaymentStatus(String orderId, String newStatus, String paymentMethod) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    await (db.update(db.localOrders)..where((t) => t.id.equals(orderId)))
        .write(LocalOrdersCompanion(
          paymentStatus: Value(newStatus),
          paymentMethod: Value(paymentMethod),
        ));

    // Queue sync action
    await sync.queueAction(
      actionType: 'UPDATE',
      tableName: 'orders',
      recordId: orderId,
      payload: {
        'payment_status': newStatus,
        'payment_method': paymentMethod,
      },
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // 1. Restore stock first
    final oldItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).get();
    for (final oldItem in oldItems) {
      final menuItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oldItem.menuItemId))).getSingleOrNull();
      if (menuItem != null) {
        // Restore stock by positive adjustment
        if (menuItem.stockQuantity > 0) {
          final newStock = menuItem.stockQuantity + oldItem.quantity;
          await (db.update(db.localMenuItems)..where((t) => t.id.equals(menuItem.id)))
              .write(LocalMenuItemsCompanion(stockQuantity: Value(newStock)));
        }
      }
    }

    // 2. Mark order as cancelled
    await (db.update(db.localOrders)..where((t) => t.id.equals(orderId)))
        .write(const LocalOrdersCompanion(status: Value('cancelled')));

    // 3. Queue status sync
    await sync.queueAction(
      actionType: 'UPDATE',
      tableName: 'orders',
      recordId: orderId,
      payload: {'status': 'cancelled'},
    );
  }

  Future<void> returnOrder(String orderId) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    // 1. Restore stock first
    final oldItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).get();
    for (final oldItem in oldItems) {
      final menuItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oldItem.menuItemId))).getSingleOrNull();
      if (menuItem != null) {
        // Restore stock by positive adjustment
        if (menuItem.stockQuantity > 0) {
          final newStock = menuItem.stockQuantity + oldItem.quantity;
          await (db.update(db.localMenuItems)..where((t) => t.id.equals(menuItem.id)))
              .write(LocalMenuItemsCompanion(stockQuantity: Value(newStock)));
        }
      }
    }

    // 2. Mark order as returned
    await (db.update(db.localOrders)..where((t) => t.id.equals(orderId)))
        .write(const LocalOrdersCompanion(
          status: Value('returned'),
          paymentStatus: Value('refunded'),
        ));

    // 3. Queue status sync
    await sync.queueAction(
      actionType: 'UPDATE',
      tableName: 'orders',
      recordId: orderId,
      payload: {
        'status': 'returned',
        'payment_status': 'refunded',
      },
    );
  }


  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// Global accessor for backward compatibility
OrdersController get ordersNotifierProvider => Get.find<OrdersController>();
