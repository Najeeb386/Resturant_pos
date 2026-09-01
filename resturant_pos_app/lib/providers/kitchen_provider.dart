import 'dart:async';
import 'package:get/get.dart';
import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/providers/orders_provider.dart';
import 'package:resturant_pos_app/core/utils/sound_helper/sound_helper.dart';

class KitchenController extends GetxController {
  final RxList<OrderWithDetails> kitchenOrders = <OrderWithDetails>[].obs;
  StreamSubscription? _subscription;
  List<String> _previousOrderIds = [];

  @override
  void onInit() {
    super.onInit();
    bindStream();
  }

  void bindStream() {
    final db = databaseProvider;
    final auth = authProvider.state.value;

    if (auth.restaurant == null) {
      kitchenOrders.clear();
      _previousOrderIds.clear();
      return;
    }

    if (auth.restaurant!.kitchenBypass) {
      kitchenOrders.clear();
      _previousOrderIds.clear();
      return;
    }

    final restaurantId = auth.restaurant!.id;

    final query = db.select(db.localOrders)
      ..where((t) => t.restaurantId.equals(restaurantId))
      ..where((t) => t.status.isIn(['pending', 'preparing', 'ready', 'draft']))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]);

    _subscription?.cancel();
    _subscription = query.watch().asyncMap((ordersList) async {
      final List<OrderWithDetails> results = [];
      for (final order in ordersList) {
        LocalTable? table;
        if (order.tableId != null) {
          table = await (db.select(db.localTables)..where((t) => t.id.equals(order.tableId!))).getSingleOrNull();
        }

        final oItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(order.id))).get();
        
        final List<OrderItemWithMenu> itemsWithMenu = [];
        for (final oItem in oItems) {
          final mItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oItem.menuItemId))).getSingleOrNull();
          itemsWithMenu.add(OrderItemWithMenu(orderItem: oItem, menuItem: mItem));
        }

        results.add(OrderWithDetails(order: order, table: table, items: itemsWithMenu));
      }
      return results;
    }).listen((data) {
      final currentIds = data.map((d) => d.order.id).toList();
      final newIds = currentIds.where((id) => !_previousOrderIds.contains(id)).toList();

      if (_previousOrderIds.isNotEmpty && newIds.isNotEmpty) {
        final hasNewCookingTicket = data.any((d) => newIds.contains(d.order.id) && (d.order.status == 'pending' || d.order.status == 'draft'));
        if (hasNewCookingTicket) {
          playNotificationSound();
        }
      }

      _previousOrderIds = currentIds;
      kitchenOrders.assignAll(data);
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// Global accessor
KitchenController get kitchenOrdersProvider => Get.find<KitchenController>();
