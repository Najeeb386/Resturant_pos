class MenuCategory {
  final int id;
  final String name;
  final String? description;

  MenuCategory({required this.id, required this.name, this.description});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}

class MenuItemVariant {
  final int id;
  final int menuItemId;
  final String name;
  final double price;
  final double costPrice;

  MenuItemVariant({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    this.costPrice = 0.0,
  });

  factory MenuItemVariant.fromJson(Map<String, dynamic> json) {
    return MenuItemVariant(
      id: json['id'] ?? 0,
      menuItemId: json['menu_item_id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'menu_item_id': menuItemId,
    'name': name,
    'price': price,
    'cost_price': costPrice,
  };
}

class MenuItem {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String? image;
  final bool isDeal;
  final List<MenuItemVariant> variants;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.costPrice = 0.0,
    required this.stockQuantity,
    this.image,
    this.isDeal = false,
    this.variants = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    var rawVars = json['variants'] as List? ?? [];
    List<MenuItemVariant> parsedVars = rawVars.map((v) => MenuItemVariant.fromJson(v)).toList();

    return MenuItem(
      id: json['id'],
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? '0') ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      image: json['image'],
      isDeal: json['is_deal'] == 1 || json['is_deal'] == true,
      variants: parsedVars,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'cost_price': costPrice,
    'stock_quantity': stockQuantity,
    'image': image,
    'is_deal': isDeal ? 1 : 0,
    'variants': variants.map((v) => v.toJson()).toList(),
  };
}

class TableModel {
  final int id;
  final String tableNumber;
  final int capacity;
  final String status; // available | occupied | reserved | cleaning

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      tableNumber: json['table_number']?.toString() ?? '',
      capacity: json['capacity'] ?? 4,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'table_number': tableNumber,
    'capacity': capacity,
    'status': status,
  };
}

class CartItem {
  final int menuItemId;
  final int? variantId;
  final String cartKey;
  final String name;
  final double price;
  int qty;

  CartItem({
    required this.menuItemId,
    this.variantId,
    required this.cartKey,
    required this.name,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'variant_id': variantId,
    'cart_key': cartKey,
    'name': name,
    'price': price,
    'qty': qty,
  };
}

class OrderModel {
  final String localId;
  final int? serverId;
  final int? tableId;
  final String orderType; // takeaway | dine_in | delivery
  final String customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final bool synced;
  final String createdAt;
  final List<CartItem> items;

  OrderModel({
    required this.localId,
    this.serverId,
    this.tableId,
    required this.orderType,
    required this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.synced = false,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      localId: json['local_id'] ?? json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: json['id'],
      tableId: json['table_id'],
      orderType: json['order_type'] ?? 'takeaway',
      customerName: json['customer_name'] ?? 'Walk-in',
      customerPhone: json['customer_phone'],
      deliveryAddress: json['delivery_address'],
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      tax: double.tryParse(json['tax'].toString()) ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'Cash',
      paymentStatus: json['payment_status'] ?? 'paid',
      status: json['status'] ?? 'completed',
      synced: json['synced'] == 1 || json['synced'] == true || json['id'] != null,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      items: (json['items'] as List? ?? []).map((i) => CartItem(
        menuItemId: i['menu_item_id'] ?? i['id'] ?? 0,
        variantId: i['variant_id'],
        cartKey: i['cart_key'] ?? '${i['id']}',
        name: i['name'] ?? i['menu_item']?['name'] ?? 'Item',
        price: double.tryParse(i['price'].toString()) ?? 0.0,
        qty: i['quantity'] ?? i['qty'] ?? 1,
      )).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'local_id': localId,
    'server_id': serverId,
    'table_id': tableId,
    'order_type': orderType,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'delivery_address': deliveryAddress,
    'subtotal': subtotal,
    'tax': tax,
    'delivery_fee': deliveryFee,
    'total': total,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'status': status,
    'synced': synced ? 1 : 0,
    'created_at': createdAt,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class InventoryModel {
  final int id;
  final String name;
  final String unit;
  final double quantity;
  final double minQuantity;
  final String? expiryDate;

  InventoryModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minQuantity,
    this.expiryDate,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      unit: json['unit'] ?? 'kg',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      minQuantity: double.tryParse(json['min_quantity'].toString()) ?? 0.0,
      expiryDate: json['expiry_date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unit': unit,
    'quantity': quantity,
    'min_quantity': minQuantity,
    'expiry_date': expiryDate,
  };
}

class ExpenseModel {
  final int id;
  final double amount;
  final String category;
  final String date;
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category'] ?? 'Other',
      date: json['date'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'date': date,
    'notes': notes,
  };
}
