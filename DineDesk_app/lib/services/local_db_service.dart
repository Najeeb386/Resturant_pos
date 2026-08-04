import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dinedesk_pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_items(
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        name TEXT,
        description TEXT,
        price REAL,
        cost_price REAL,
        stock_quantity INTEGER,
        image TEXT,
        is_deal INTEGER,
        variants_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tables(
        id INTEGER PRIMARY KEY,
        table_number TEXT,
        capacity INTEGER,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders(
        local_id TEXT PRIMARY KEY,
        server_id INTEGER,
        table_id INTEGER,
        order_type TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        delivery_address TEXT,
        subtotal REAL,
        tax REAL,
        delivery_fee REAL,
        total REAL,
        payment_method TEXT,
        payment_status TEXT,
        status TEXT,
        synced INTEGER,
        created_at TEXT,
        items_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory(
        id INTEGER PRIMARY KEY,
        name TEXT,
        unit TEXT,
        quantity REAL,
        min_quantity REAL,
        expiry_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        category TEXT,
        date TEXT,
        notes TEXT
      )
    ''');
  }

  // --- Categories ---
  Future<void> saveCategories(List<MenuCategory> categories) async {
    final db = await database;
    Batch batch = db.batch();
    batch.delete('categories');
    for (var c in categories) {
      batch.insert('categories', c.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<MenuCategory>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => MenuCategory.fromJson(m)).toList();
  }

  // --- Menu Items ---
  Future<void> saveMenuItems(List<MenuItem> items) async {
    final db = await database;
    Batch batch = db.batch();
    batch.delete('menu_items');
    for (var item in items) {
      Map<String, dynamic> row = item.toJson();
      row['variants_json'] = jsonEncode(item.variants.map((v) => v.toJson()).toList());
      row.remove('variants');
      batch.insert('menu_items', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<MenuItem>> getMenuItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');
    return maps.map((m) {
      Map<String, dynamic> mutableMap = Map<String, dynamic>.from(m);
      if (mutableMap['variants_json'] != null) {
        mutableMap['variants'] = jsonDecode(mutableMap['variants_json']);
      }
      return MenuItem.fromJson(mutableMap);
    }).toList();
  }

  // --- Tables ---
  Future<void> saveTables(List<TableModel> tables) async {
    final db = await database;
    Batch batch = db.batch();
    batch.delete('tables');
    for (var t in tables) {
      batch.insert('tables', t.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<TableModel>> getTables() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tables');
    return maps.map((m) => TableModel.fromJson(m)).toList();
  }

  // --- Orders ---
  Future<void> saveOrder(OrderModel order) async {
    final db = await database;
    Map<String, dynamic> row = order.toJson();
    row['items_json'] = jsonEncode(order.items.map((i) => i.toJson()).toList());
    row.remove('items');

    await db.insert('orders', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders', orderBy: 'created_at DESC');
    return maps.map((m) {
      Map<String, dynamic> mutableMap = Map<String, dynamic>.from(m);
      if (mutableMap['items_json'] != null) {
        mutableMap['items'] = jsonDecode(mutableMap['items_json']);
      }
      return OrderModel.fromJson(mutableMap);
    }).toList();
  }

  Future<List<OrderModel>> getUnsyncedOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders', where: 'synced = 0');
    return maps.map((m) {
      Map<String, dynamic> mutableMap = Map<String, dynamic>.from(m);
      if (mutableMap['items_json'] != null) {
        mutableMap['items'] = jsonDecode(mutableMap['items_json']);
      }
      return OrderModel.fromJson(mutableMap);
    }).toList();
  }

  Future<void> markOrdersAsSynced(List<String> localIds) async {
    final db = await database;
    Batch batch = db.batch();
    for (var id in localIds) {
      batch.update('orders', {'synced': 1}, where: 'local_id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }
}
