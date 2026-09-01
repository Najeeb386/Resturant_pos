import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';
import 'package:resturant_pos_app/providers/database_provider.dart';
import 'package:resturant_pos_app/core/utils/sound_helper/sound_helper.dart';

class CartItem {
  final LocalMenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  CartItem copyWith({LocalMenuItem? item, int? quantity}) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class PosState {
  final List<CartItem> cart;
  final LocalTable? selectedTable;
  final String orderType; // dine_in, takeaway, delivery
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double deliveryFee;
  final double discount;
  final String? activeDraftOrderId; // If editing an existing draft
  final String paymentMethod;
  final String? error;
  final bool isSaving;

  PosState({
    this.cart = const [],
    this.selectedTable,
    this.orderType = 'takeaway',
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    this.activeDraftOrderId,
    this.paymentMethod = 'Cash',
    this.error,
    this.isSaving = false,
  });

  double get subtotal => cart.fold(0.0, (sum, element) => sum + (element.item.price * element.quantity));
  
  double getTax(double taxPercentage) => subtotal * (taxPercentage / 100);
  
  double getTotal(double taxPercentage) => subtotal + getTax(taxPercentage) + deliveryFee - discount;

  PosState copyWith({
    List<CartItem>? cart,
    LocalTable? selectedTable,
    String? orderType,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    double? deliveryFee,
    double? discount,
    String? activeDraftOrderId,
    String? paymentMethod,
    String? error,
    bool? isSaving,
  }) {
    return PosState(
      cart: cart ?? this.cart,
      selectedTable: selectedTable ?? this.selectedTable,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      activeDraftOrderId: activeDraftOrderId ?? this.activeDraftOrderId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      error: error ?? this.error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class PosController extends GetxController {
  final Rx<PosState> state = PosState().obs;
  LocalOrder? lastCompletedOrder;
  List<CartItem> lastCompletedItems = [];
  LocalTable? lastCompletedTable;

  void addToCart(LocalMenuItem item) {
    final existingIndex = state.value.cart.indexWhere((element) => element.item.id == item.id);
    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(state.value.cart);
      updated[existingIndex].quantity += 1;
      state.value = state.value.copyWith(cart: updated);
    } else {
      state.value = state.value.copyWith(cart: [...state.value.cart, CartItem(item: item)]);
    }
  }

  void updateQuantity(String itemId, int newQty) {
    if (newQty <= 0) {
      removeFromCart(itemId);
      return;
    }
    final updated = state.value.cart.map((e) {
      if (e.item.id == itemId) {
        return e.copyWith(quantity: newQty);
      }
      return e;
    }).toList();
    state.value = state.value.copyWith(cart: updated);
  }

  void removeFromCart(String itemId) {
    state.value = state.value.copyWith(
      cart: state.value.cart.where((element) => element.item.id != itemId).toList(),
    );
  }

  void setOrderType(String type) {
    state.value = state.value.copyWith(
      orderType: type,
      selectedTable: type == 'dine_in' ? state.value.selectedTable : null,
    );
  }

  void setSelectedTable(LocalTable? table) {
    state.value = state.value.copyWith(selectedTable: table);
  }

  void setCustomerDetails({String? name, String? phone, String? address}) {
    state.value = state.value.copyWith(
      customerName: name ?? state.value.customerName,
      customerPhone: phone ?? state.value.customerPhone,
      deliveryAddress: address ?? state.value.deliveryAddress,
    );
  }

  void setFinances({double? deliveryFee, double? discount}) {
    state.value = state.value.copyWith(
      deliveryFee: deliveryFee ?? state.value.deliveryFee,
      discount: discount ?? state.value.discount,
    );
  }

  void setPaymentMethod(String method) {
    state.value = state.value.copyWith(paymentMethod: method);
  }

  void clearCart() {
    state.value = PosState(orderType: state.value.orderType);
  }

  // Load a Draft order into the cart
  Future<void> loadDraft(String orderId) async {
    final db = databaseProvider;
    
    final order = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
    if (order == null) return;

    final orderItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).get();
    
    final List<CartItem> loadedCart = [];
    for (final oItem in orderItems) {
      final menuItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oItem.menuItemId))).getSingleOrNull();
      if (menuItem != null) {
        loadedCart.add(CartItem(item: menuItem, quantity: oItem.quantity));
      }
    }

    LocalTable? table;
    if (order.tableId != null) {
      table = await (db.select(db.localTables)..where((t) => t.id.equals(order.tableId!))).getSingleOrNull();
    }

    state.value = PosState(
      cart: loadedCart,
      selectedTable: table,
      orderType: order.orderType,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      deliveryAddress: order.deliveryAddress,
      deliveryFee: order.deliveryFee,
      discount: order.discount,
      activeDraftOrderId: order.id,
    );
  }

  Future<void> deleteDraftOrder(String orderId) async {
    final db = databaseProvider;
    final sync = syncManagerProvider;

    try {
      // 1. Fetch order details to see if table needs releasing
      final order = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
      if (order != null && order.tableId != null) {
        // Release table
        await (db.update(db.localTables)..where((t) => t.id.equals(order.tableId!)))
            .write(const LocalTablesCompanion(status: d.Value('available')));
        
        await sync.queueAction(
          actionType: 'UPDATE',
          tableName: 'tables',
          recordId: order.tableId!,
          payload: {'status': 'available'},
        );
      }

      // 2. Delete order items
      final oItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).get();
      for (final item in oItems) {
        await (db.delete(db.localOrderItems)..where((t) => t.id.equals(item.id))).go();
        await sync.queueAction(
          actionType: 'DELETE',
          tableName: 'order_items',
          recordId: item.id,
          payload: {'id': item.id},
        );
      }

      // 3. Delete order
      await (db.delete(db.localOrders)..where((t) => t.id.equals(orderId))).go();
      await sync.queueAction(
        actionType: 'DELETE',
        tableName: 'orders',
        recordId: orderId,
        payload: {'id': orderId},
      );

      // If the currently active draft in the POS cart is this draft order, clear the cart!
      if (state.value.activeDraftOrderId == orderId) {
        clearCart();
      }
    } catch (e) {
      print('ERROR deleting draft order: $e');
    }
  }

  // Deduct/Restore inventory helpers
  Future<void> _adjustInventory(LocalMenuItem item, int qtyChange, AppDatabase db) async {
    final sync = syncManagerProvider;

    if (item.stockQuantity > 0) {
      final newStock = (item.stockQuantity + qtyChange).clamp(0, 999999);
      await (db.update(db.localMenuItems)..where((t) => t.id.equals(item.id)))
          .write(LocalMenuItemsCompanion(stockQuantity: d.Value(newStock)));

      await sync.queueAction(
        actionType: 'UPDATE',
        tableName: 'menu_items',
        recordId: item.id,
        payload: {'stock_quantity': newStock},
      );
    }

    final recipe = await (db.select(db.localMenuItemIngredients)..where((t) => t.menuItemId.equals(item.id))).get();
    for (final ingNeeded in recipe) {
      final ingredient = await (db.select(db.localIngredients)..where((t) => t.id.equals(ingNeeded.ingredientId))).getSingleOrNull();
      if (ingredient != null) {
        final double deduction = ingNeeded.quantityNeeded * qtyChange;
        final double newQty = (ingredient.quantity + deduction).clamp(0.0, 999999.9);
        
        await (db.update(db.localIngredients)..where((t) => t.id.equals(ingredient.id)))
            .write(LocalIngredientsCompanion(quantity: d.Value(newQty)));

        await sync.queueAction(
          actionType: 'UPDATE',
          tableName: 'ingredients',
          recordId: ingredient.id,
          payload: {'quantity': newQty},
        );
      }
    }
  }

  // Checkout and submit order (completed status)
  Future<bool> checkout() async {
    if (state.value.cart.isEmpty) {
      state.value = state.value.copyWith(error: 'Cart is empty');
      return false;
    }

    state.value = state.value.copyWith(isSaving: true, error: null);
    final db = databaseProvider;
    final authState = authProvider.state.value;
    final sync = syncManagerProvider;

    final restaurantId = authState.restaurant?.id ?? '00000000-0000-0000-0000-000000000000';
    final userId = authState.user?.id ?? '00000000-0000-0000-0000-000000000000';
    final taxPct = authState.restaurant?.taxPercentage ?? 18.0;

    final orderId = state.value.activeDraftOrderId ?? const Uuid().v4();
    final isEditingDraft = state.value.activeDraftOrderId != null;

    final orderSubtotal = state.value.subtotal;
    final orderTax = state.value.getTax(taxPct);
    final orderTotal = state.value.getTotal(taxPct);

    final List<Future<void> Function()> pendingSyncActions = [];

    try {
      await db.transaction(() async {
        if (isEditingDraft) {
          final oldOrder = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
          if (oldOrder != null && oldOrder.tableId != null) {
            await (db.update(db.localTables)..where((t) => t.id.equals(oldOrder.tableId!)))
                .write(const LocalTablesCompanion(status: d.Value('available')));
            
            pendingSyncActions.add(() => sync.queueAction(
              actionType: 'UPDATE',
              tableName: 'tables',
              recordId: oldOrder.tableId!,
              payload: {'status': 'available'},
            ));
          }
          
          final oldItems = await (db.select(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).get();
          for (final oldIt in oldItems) {
            final menuItem = await (db.select(db.localMenuItems)..where((t) => t.id.equals(oldIt.menuItemId))).getSingleOrNull();
            if (menuItem != null) {
              await _adjustInventory(menuItem, oldIt.quantity, db);
            }
          }

          await (db.delete(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).go();
        }

        int? nextBillNum;
        if (isEditingDraft) {
          final oldOrder = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
          nextBillNum = oldOrder?.billNumber;
        }

        if (nextBillNum == null) {
          final query = db.select(db.localOrders)
            ..where((t) => t.restaurantId.equals(restaurantId))
            ..orderBy([(t) => d.OrderingTerm(expression: t.billNumber, mode: d.OrderingMode.desc)])
            ..limit(1);
          final maxOrder = await query.getSingleOrNull();
          if (maxOrder != null && maxOrder.billNumber != null) {
            nextBillNum = maxOrder.billNumber! + 1;
          } else {
            nextBillNum = authState.restaurant?.startingBillNumber ?? 1000;
          }
        }

        final orderCompanion = LocalOrdersCompanion.insert(
          id: orderId,
          restaurantId: restaurantId,
          tableId: d.Value(state.value.selectedTable?.id),
          userId: userId,
          orderType: state.value.orderType,
          status: (authState.restaurant?.kitchenBypass ?? false) ? 'completed' : 'pending',
          paymentStatus: 'paid',
          paymentMethod: d.Value(state.value.paymentMethod),
          subtotal: orderSubtotal,
          tax: orderTax,
          discount: d.Value(state.value.discount),
          deliveryFee: d.Value(state.value.deliveryFee),
          total: orderTotal,
          customerName: d.Value(state.value.customerName),
          customerPhone: d.Value(state.value.customerPhone),
          deliveryAddress: d.Value(state.value.deliveryAddress),
          createdAt: DateTime.now(),
          billNumber: d.Value(nextBillNum),
        );

        await db.into(db.localOrders).insertOnConflictUpdate(orderCompanion);

        final List<Map<String, dynamic>> itemsPayload = [];
        for (final cartIt in state.value.cart) {
          final itemId = const Uuid().v4();
          final orderItemCompanion = LocalOrderItemsCompanion.insert(
            id: itemId,
            orderId: orderId,
            menuItemId: cartIt.item.id,
            quantity: cartIt.quantity,
            price: cartIt.item.price,
            costPrice: d.Value(cartIt.item.costPrice),
          );
          await db.into(db.localOrderItems).insert(orderItemCompanion);
          await _adjustInventory(cartIt.item, -cartIt.quantity, db);

          itemsPayload.add({
            'id': itemId,
            'order_id': orderId,
            'menu_item_id': cartIt.item.id,
            'quantity': cartIt.quantity,
            'price': cartIt.item.price,
            'cost_price': cartIt.item.costPrice,
          });
        }

        if (state.value.orderType == 'dine_in' && state.value.selectedTable != null) {
          await (db.update(db.localTables)..where((t) => t.id.equals(state.value.selectedTable!.id)))
              .write(const LocalTablesCompanion(status: d.Value('available')));
        }

        final orderMap = {
          'id': orderId,
          'restaurant_id': restaurantId,
          'table_id': state.value.selectedTable?.id,
          'user_id': userId,
          'order_type': state.value.orderType,
          'status': (authState.restaurant?.kitchenBypass ?? false) ? 'completed' : 'pending',
          'payment_status': 'paid',
          'payment_method': state.value.paymentMethod,
          'subtotal': orderSubtotal,
          'tax': orderTax,
          'discount': state.value.discount,
          'delivery_fee': state.value.deliveryFee,
          'total': orderTotal,
          'customer_name': state.value.customerName,
          'customer_phone': state.value.customerPhone,
          'delivery_address': state.value.deliveryAddress,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'bill_number': nextBillNum,
        };

        if (isEditingDraft) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'UPDATE',
            tableName: 'orders',
            recordId: orderId,
            payload: orderMap,
          ));
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'DELETE',
            tableName: 'order_items',
            recordId: orderId,
            payload: {'order_id': orderId}, 
          ));
        } else {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'INSERT',
            tableName: 'orders',
            recordId: orderId,
            payload: orderMap,
          ));
        }

        for (final it in itemsPayload) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'INSERT',
            tableName: 'order_items',
            recordId: it['id'],
            payload: it,
          ));
        }

        if (state.value.orderType == 'dine_in' && state.value.selectedTable != null) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'UPDATE',
            tableName: 'tables',
            recordId: state.value.selectedTable!.id,
            payload: {'status': 'available'},
          ));
        }
      });

      // Run sync actions cleanly outside transaction
      for (final action in pendingSyncActions) {
        await action();
      }

      // Store completed details for receipt printing
      lastCompletedItems = List<CartItem>.from(state.value.cart);
      lastCompletedTable = state.value.selectedTable;
      lastCompletedOrder = LocalOrder(
        id: orderId,
        restaurantId: restaurantId,
        tableId: state.value.selectedTable?.id,
        userId: userId,
        orderType: state.value.orderType,
        status: 'completed',
        paymentStatus: 'paid',
        paymentMethod: state.value.paymentMethod,
        subtotal: orderSubtotal,
        tax: orderTax,
        discount: state.value.discount,
        deliveryFee: state.value.deliveryFee,
        total: orderTotal,
        customerName: state.value.customerName,
        customerPhone: state.value.customerPhone,
        deliveryAddress: state.value.deliveryAddress,
        notes: null,
        createdAt: DateTime.now(),
      );

      clearCart();
      state.value = state.value.copyWith(isSaving: false);

      final hasKitchen = authState.restaurant?.hasKitchen ?? true;
      final kitchenBypass = authState.restaurant?.kitchenBypass ?? false;
      if (hasKitchen && !kitchenBypass) {
        playNotificationSound();
        Get.snackbar(
          'Kitchen Alert',
          'Order #${orderId.substring(0, 5).toUpperCase()} sent to Kitchen Monitor successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.kitchen_outlined, color: Colors.white, size: 28),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Order Complete',
          'Order #${orderId.substring(0, 5).toUpperCase()} processed successfully (Kitchen Bypassed).',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blueGrey,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }

      return true;
    } catch (e) {
      state.value = state.value.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  // Save as Draft order (dine_in bills, unpaid open orders)
  Future<bool> saveAsDraft() async {
    if (state.value.cart.isEmpty) {
      state.value = state.value.copyWith(error: 'Cart is empty');
      return false;
    }

    state.value = state.value.copyWith(isSaving: true, error: null);
    final db = databaseProvider;
    final authState = authProvider.state.value;
    final sync = syncManagerProvider;

    final restaurantId = authState.restaurant?.id ?? '00000000-0000-0000-0000-000000000000';
    final userId = authState.user?.id ?? '00000000-0000-0000-0000-000000000000';
    final taxPct = authState.restaurant?.taxPercentage ?? 18.0;

    final orderId = state.value.activeDraftOrderId ?? const Uuid().v4();
    final isEditingDraft = state.value.activeDraftOrderId != null;

    final orderSubtotal = state.value.subtotal;
    final orderTax = state.value.getTax(taxPct);
    final orderTotal = state.value.getTotal(taxPct);

    final List<Future<void> Function()> pendingSyncActions = [];

    try {
      await db.transaction(() async {
        if (isEditingDraft) {
          final oldOrder = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
          if (oldOrder != null && oldOrder.tableId != null) {
            await (db.update(db.localTables)..where((t) => t.id.equals(oldOrder.tableId!)))
                .write(const LocalTablesCompanion(status: d.Value('available')));
            pendingSyncActions.add(() => sync.queueAction(
              actionType: 'UPDATE',
              tableName: 'tables',
              recordId: oldOrder.tableId!,
              payload: {'status': 'available'},
            ));
          }
          await (db.delete(db.localOrderItems)..where((t) => t.orderId.equals(orderId))).go();
        }

        int? nextBillNum;
        if (isEditingDraft) {
          final oldOrder = await (db.select(db.localOrders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
          nextBillNum = oldOrder?.billNumber;
        }

        if (nextBillNum == null) {
          final query = db.select(db.localOrders)
            ..where((t) => t.restaurantId.equals(restaurantId))
            ..orderBy([(t) => d.OrderingTerm(expression: t.billNumber, mode: d.OrderingMode.desc)])
            ..limit(1);
          final maxOrder = await query.getSingleOrNull();
          if (maxOrder != null && maxOrder.billNumber != null) {
            nextBillNum = maxOrder.billNumber! + 1;
          } else {
            nextBillNum = authState.restaurant?.startingBillNumber ?? 1000;
          }
        }

        final orderCompanion = LocalOrdersCompanion.insert(
          id: orderId,
          restaurantId: restaurantId,
          tableId: d.Value(state.value.selectedTable?.id),
          userId: userId,
          orderType: state.value.orderType,
          status: 'draft',
          paymentStatus: 'unpaid',
          paymentMethod: const d.Value('Cash'),
          subtotal: orderSubtotal,
          tax: orderTax,
          discount: d.Value(state.value.discount),
          deliveryFee: d.Value(state.value.deliveryFee),
          total: orderTotal,
          customerName: d.Value(state.value.customerName),
          customerPhone: d.Value(state.value.customerPhone),
          deliveryAddress: d.Value(state.value.deliveryAddress),
          createdAt: DateTime.now(),
          billNumber: d.Value(nextBillNum),
        );

        await db.into(db.localOrders).insertOnConflictUpdate(orderCompanion);

        final List<Map<String, dynamic>> itemsPayload = [];
        for (final cartIt in state.value.cart) {
          final itemId = const Uuid().v4();
          final orderItemCompanion = LocalOrderItemsCompanion.insert(
            id: itemId,
            orderId: orderId,
            menuItemId: cartIt.item.id,
            quantity: cartIt.quantity,
            price: cartIt.item.price,
            costPrice: d.Value(cartIt.item.costPrice),
          );
          await db.into(db.localOrderItems).insert(orderItemCompanion);

          itemsPayload.add({
            'id': itemId,
            'order_id': orderId,
            'menu_item_id': cartIt.item.id,
            'quantity': cartIt.quantity,
            'price': cartIt.item.price,
            'cost_price': cartIt.item.costPrice,
          });
        }

        if (state.value.orderType == 'dine_in' && state.value.selectedTable != null) {
          await (db.update(db.localTables)..where((t) => t.id.equals(state.value.selectedTable!.id)))
              .write(const LocalTablesCompanion(status: d.Value('occupied')));
        }

        final orderMap = {
          'id': orderId,
          'restaurant_id': restaurantId,
          'table_id': state.value.selectedTable?.id,
          'user_id': userId,
          'order_type': state.value.orderType,
          'status': 'draft',
          'payment_status': 'unpaid',
          'payment_method': 'Cash',
          'subtotal': orderSubtotal,
          'tax': orderTax,
          'discount': state.value.discount,
          'delivery_fee': state.value.deliveryFee,
          'total': orderTotal,
          'customer_name': state.value.customerName,
          'customer_phone': state.value.customerPhone,
          'delivery_address': state.value.deliveryAddress,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'bill_number': nextBillNum,
        };

        if (isEditingDraft) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'UPDATE',
            tableName: 'orders',
            recordId: orderId,
            payload: orderMap,
          ));
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'DELETE',
            tableName: 'order_items',
            recordId: orderId,
            payload: {'order_id': orderId},
          ));
        } else {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'INSERT',
            tableName: 'orders',
            recordId: orderId,
            payload: orderMap,
          ));
        }

        for (final it in itemsPayload) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'INSERT',
            tableName: 'order_items',
            recordId: it['id'],
            payload: it,
          ));
        }

        if (state.value.orderType == 'dine_in' && state.value.selectedTable != null) {
          pendingSyncActions.add(() => sync.queueAction(
            actionType: 'UPDATE',
            tableName: 'tables',
            recordId: state.value.selectedTable!.id,
            payload: {'status': 'occupied'},
          ));
        }
      });

      // Run sync actions cleanly outside transaction
      for (final action in pendingSyncActions) {
        await action();
      }

      clearCart();
      state.value = state.value.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

// Global accessor for PosState
PosController get posProvider => Get.find<PosController>();
