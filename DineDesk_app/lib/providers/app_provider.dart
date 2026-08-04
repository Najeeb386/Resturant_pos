import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/local_db_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

class AppProvider extends ChangeNotifier {
  final LocalDbService _dbService = LocalDbService();
  final SyncService _syncService = SyncService();

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
  void addToCart(MenuItem item) {
    int existingIndex = _cart.indexWhere((c) => c.menuItemId == item.id && c.variantId == null);
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
  }

  void addVariantToCart(MenuItem item, MenuItemVariant variant) {
    String cartKey = '${item.id}-${variant.id}';
    String name = '${item.name} (${variant.name})';

    int existingIndex = _cart.indexWhere((c) => c.cartKey == cartKey);
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
  }

  void updateCartQty(String cartKey, int delta) {
    int index = _cart.indexWhere((c) => c.cartKey == cartKey);
    if (index > -1) {
      int newQty = _cart[index].qty + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].qty = newQty;
      }
      notifyListeners();
    }
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
    await _syncService.updatePendingCount();
    notifyListeners();
  }

  Future<void> refreshFromApi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
      }
    } catch (e) {
      _errorMessage = 'Offline mode active. Loaded cached data.';
      await loadLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Complete Order (Offline-First) ---
  Future<OrderModel> submitOrder() async {
    if (_cart.isEmpty) throw Exception('Cart is empty');

    String localId = DateTime.now().millisecondsSinceEpoch.toString();
    OrderModel order = OrderModel(
      localId: localId,
      tableId: _selectedTableId,
      orderType: _orderType,
      customerName: _customerName.isEmpty ? 'Walk-in' : _customerName,
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
    _orders.insert(0, order);
    clearCart();

    // Trigger async sync if online
    _syncService.autoSyncPendingOrders().then((_) {
      loadLocalData();
    });

    return order;
  }
}
