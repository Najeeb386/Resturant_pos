import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/local_db_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

class AppProvider extends ChangeNotifier {
  final LocalDbService _dbService = LocalDbService();
  final SyncService _syncService = SyncService();
  Timer? _pollingTimer;

  bool _isLoading = false;
  String? _errorMessage;

  List<MenuCategory> _categories = [];
  List<MenuItem> _menuItems = [];
  List<TableModel> _tables = [];
  List<OrderModel> _orders = [];
  List<InventoryModel> _inventory = [];
  List<ExpenseModel> _expenses = [];

  // Active POS state
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _orderType = 'takeaway'; // takeaway | dine_in | delivery
  int? _selectedTableId;
  String _customerName = '';
  String _customerPhone = '';
  String _deliveryAddress = '';
  double _deliveryFee = 0.0;
  String _paymentMethod = 'Cash';

  List<CartItem> _cart = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SyncStatus get syncStatus => _syncService.status;
  int get pendingSyncCount => _syncService.pendingCount;

  List<MenuCategory> get categories => _categories;
  List<MenuItem> get menuItems => _menuItems;
  List<TableModel> get tables => _tables;
  List<OrderModel> get orders => _orders;
  List<InventoryModel> get inventory => _inventory;
  List<ExpenseModel> get expenses => _expenses;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get orderType => _orderType;
  int? get selectedTableId => _selectedTableId;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get deliveryAddress => _deliveryAddress;
  double get deliveryFee => _deliveryFee;
  String get paymentMethod => _paymentMethod;

  List<CartItem> get cart => _cart;

  double get subtotal => _cart.fold(0, (sum, i) => sum + (i.price * i.qty));
  double get tax => subtotal * 0.10; // 10% default tax
  double get total => subtotal + tax + (_orderType == 'delivery' ? _deliveryFee : 0);

  AppProvider() {
    _syncService.initNetworkListener(() {
      notifyListeners();
    });
    loadLocalData();
    _startSilentPolling();
  }

  void _startSilentPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      refreshFromApi(silent: true);
    });
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSelectedCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setOrderType(String type) {
    _orderType = type;
    if (type != 'dine_in') _selectedTableId = null;
    notifyListeners();
  }

  void setSelectedTableId(int? id) {
    _selectedTableId = id;
    notifyListeners();
  }

  void setCustomerInfo({String? name, String? phone, String? address, double? fee}) {
    if (name != null) _customerName = name;
    if (phone != null) _customerPhone = phone;
    if (address != null) _deliveryAddress = address;
    if (fee != null) _deliveryFee = fee;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // --- Cart Actions ---
  bool addToCart(MenuItem item) {
    if (item.stockQuantity <= 0) return false;

    int existingIndex = _cart.indexWhere((c) => c.menuItemId == item.id && c.variantId == null);
    int currentQty = existingIndex > -1 ? _cart[existingIndex].qty : 0;
    
    if ((currentQty + 1) > item.stockQuantity) {
      return false; // Stock limit reached
    }

    if (existingIndex > -1) {
      _cart[existingIndex].qty += 1;
    } else {
      _cart.add(CartItem(
        menuItemId: item.id,
        cartKey: '${item.id}',
        name: item.name,
        price: item.price,
        qty: 1,
      ));
    }
    notifyListeners();
    return true;
  }

  bool addVariantToCart(MenuItem item, MenuItemVariant variant) {
    if (item.stockQuantity <= 0) return false;

    String cartKey = '${item.id}-${variant.id}';
    String name = '${item.name} (${variant.name})';

    int existingIndex = _cart.indexWhere((c) => c.cartKey == cartKey);
    int currentQty = existingIndex > -1 ? _cart[existingIndex].qty : 0;

    if ((currentQty + 1) > item.stockQuantity) {
      return false; // Stock limit reached
    }

    if (existingIndex > -1) {
      _cart[existingIndex].qty += 1;
    } else {
      _cart.add(CartItem(
        menuItemId: item.id,
        variantId: variant.id,
        cartKey: cartKey,
        name: name,
        price: variant.price,
        qty: 1,
      ));
    }
    notifyListeners();
    return true;
  }

  bool updateCartQty(String cartKey, int delta) {
    int index = _cart.indexWhere((c) => c.cartKey == cartKey);
    if (index > -1) {
      int currentQty = _cart[index].qty;
      int newQty = currentQty + delta;

      if (delta > 0) {
        MenuItem? menuItem;
        try {
          menuItem = _menuItems.firstWhere((m) => m.id == _cart[index].menuItemId);
        } catch (_) {
          menuItem = null;
        }

        if (menuItem != null && newQty > menuItem.stockQuantity) {
          return false; // Stock limit reached
        }
      }

      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].qty = newQty;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearCart() {
    _cart.clear();
    _customerName = '';
    _customerPhone = '';
    _deliveryAddress = '';
    _deliveryFee = 0.0;
    _selectedTableId = null;
    notifyListeners();
  }

  // --- Load Data Offline & Sync ---
  Future<void> loadLocalData() async {
    _categories = await _dbService.getCategories();
    _menuItems = await _dbService.getMenuItems();
    _tables = await _dbService.getTables();
    _orders = await _dbService.getOrders();

    // Populate persistent draft bills from local storage
    _drafts = _orders.where((o) => o.paymentStatus == 'unpaid' || o.status == 'pending' || o.status == 'draft').toList();
    _drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _syncService.updatePendingCount();
    notifyListeners();
  }

  Future<void> refreshFromApi({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      var data = await ApiService.fetchBootstrapData();
      if (data['categories'] != null) {
        _categories = (data['categories'] as List).map((c) => MenuCategory.fromJson(c)).toList();
        await _dbService.saveCategories(_categories);
      }
      if (data['menu_items'] != null) {
        _menuItems = (data['menu_items'] as List).map((m) => MenuItem.fromJson(m)).toList();
        await _dbService.saveMenuItems(_menuItems);
      }
      if (data['tables'] != null) {
        _tables = (data['tables'] as List).map((t) => TableModel.fromJson(t)).toList();
        await _dbService.saveTables(_tables);
      }
      if (data['orders'] != null) {
        _orders = (data['orders'] as List).map((o) => OrderModel.fromJson(o)).toList();
        for (var o in _orders) {
          await _dbService.saveOrder(o);
        }
        _drafts = _orders.where((o) => o.paymentStatus == 'unpaid' || o.status == 'pending' || o.status == 'draft').toList();
        _drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      if (!silent) {
        _errorMessage = 'Offline mode active. Loaded cached data.';
        await loadLocalData();
      }
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  List<OrderModel> _drafts = [];
  String? _editingDraftLocalId;

  List<OrderModel> get drafts => _drafts;

  // --- Draft Bills Actions ---
  void saveAsDraft() {
    if (_cart.isEmpty) return;

    String localId = _editingDraftLocalId ?? 'DRAFT-${DateTime.now().millisecondsSinceEpoch}';
    OrderModel draft = OrderModel(
      localId: localId,
      tableId: _selectedTableId,
      orderType: _orderType,
      customerName: _customerName.isEmpty 
          ? (_selectedTableId != null ? 'Table $_selectedTableId (Dine-In)' : 'Walk-in (Draft)') 
          : _customerName,
      customerPhone: _customerPhone,
      deliveryAddress: _deliveryAddress,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: _deliveryFee,
      total: total,
      paymentMethod: _paymentMethod,
      paymentStatus: 'unpaid',
      status: 'pending', // Marked pending so it sends kitchen order notification!
      synced: false,
      createdAt: DateTime.now().toIso8601String(),
      items: List.from(_cart),
    );

    int existingDraftIndex = _drafts.indexWhere((d) => d.localId == localId);
    if (existingDraftIndex > -1) {
      _drafts[existingDraftIndex] = draft;
    } else {
      _drafts.insert(0, draft);
    }

    int existingOrderIndex = _orders.indexWhere((o) => o.localId == localId);
    if (existingOrderIndex > -1) {
      _orders[existingOrderIndex] = draft;
    } else {
      _orders.insert(0, draft);
    }

    _dbService.saveOrder(draft);
    _editingDraftLocalId = null;
    clearCart();

    _syncService.autoSyncPendingOrders().then((_) {
      loadLocalData();
    });

    notifyListeners();
  }

  void loadDraft(OrderModel draft) {
    _editingDraftLocalId = draft.localId;
    _cart = List.from(draft.items);
    _orderType = draft.orderType;
    _selectedTableId = draft.tableId;
    _customerName = draft.customerName;
    _customerPhone = draft.customerPhone ?? '';
    _deliveryAddress = draft.deliveryAddress ?? '';
    _deliveryFee = draft.deliveryFee;

    notifyListeners();
  }

  void deleteDraft(String localId) {
    _drafts.removeWhere((d) => d.localId == localId);
    _orders.removeWhere((o) => o.localId == localId);
    if (_editingDraftLocalId == localId) {
      _editingDraftLocalId = null;
    }
    notifyListeners();
  }

  void updateOrder(OrderModel updated) {
    int idx = _orders.indexWhere((o) => o.localId == updated.localId);
    if (idx > -1) {
      _orders[idx] = updated;
      _dbService.saveOrder(updated);
      notifyListeners();
    }
  }

  // --- Order Status Management ---
  void updateOrderStatus(String localId, String newStatus) {
    int idx = _orders.indexWhere((o) => o.localId == localId);
    if (idx > -1) {
      OrderModel old = _orders[idx];
      OrderModel updated = OrderModel(
        localId: old.localId,
        serverId: old.serverId,
        tableId: old.tableId,
        orderType: old.orderType,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        deliveryAddress: old.deliveryAddress,
        subtotal: old.subtotal,
        tax: old.tax,
        deliveryFee: old.deliveryFee,
        total: old.total,
        paymentMethod: old.paymentMethod,
        paymentStatus: old.paymentStatus,
        status: newStatus,
        synced: false,
        createdAt: old.createdAt,
        items: old.items,
      );

      _orders[idx] = updated;
      _dbService.saveOrder(updated);
      notifyListeners();
    }
  }

  void cancelOrder(String localId) {
    updateOrderStatus(localId, 'cancelled');
  }

  // --- Complete Order (Offline-First) ---
  Future<OrderModel> submitOrder() async {
    if (_cart.isEmpty) throw Exception('Cart is empty');

    String localId = _editingDraftLocalId ?? DateTime.now().millisecondsSinceEpoch.toString();
    OrderModel order = OrderModel(
      localId: localId,
      tableId: _selectedTableId,
      orderType: _orderType,
      customerName: _customerName.isEmpty 
          ? (_selectedTableId != null ? 'Table $_selectedTableId' : 'Walk-in') 
          : _customerName,
      customerPhone: _customerPhone,
      deliveryAddress: _deliveryAddress,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: _deliveryFee,
      total: total,
      paymentMethod: _paymentMethod,
      paymentStatus: 'paid',
      status: 'completed',
      synced: false,
      createdAt: DateTime.now().toIso8601String(),
      items: List.from(_cart),
    );

    await _dbService.saveOrder(order);

    int existingIdx = _orders.indexWhere((o) => o.localId == localId);
    if (existingIdx > -1) {
      _orders[existingIdx] = order;
    } else {
      _orders.insert(0, order);
    }

    _drafts.removeWhere((d) => d.localId == localId);
    _editingDraftLocalId = null;

    clearCart();

    // Trigger async sync if online
    _syncService.autoSyncPendingOrders().then((_) {
      loadLocalData();
    });

    return order;
  }
}
