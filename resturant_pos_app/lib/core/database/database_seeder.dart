import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'local_database.dart';

class DatabaseSeeder {
  static Future<void> seed(AppDatabase db, String restaurantId, String userId) async {
    return; // Completely disabled seeder
  }

  static Future<void> _oldSeed(AppDatabase db, String restaurantId, String userId) async {
    // 1. Check if database already has categories. If not empty, skip seeding.
    final existingCategories = await db.select(db.localMenuCategories).get();
    if (existingCategories.isNotEmpty) {
      return;
    }

    print('Seeding database with demo data for restaurant: $restaurantId...');

    await db.transaction(() async {
      // 2. Define Categories
      final categories = [
        {'id': const Uuid().v4(), 'name': 'Burgers'},
        {'id': const Uuid().v4(), 'name': 'Pizzas'},
        {'id': const Uuid().v4(), 'name': 'Sides'},
        {'id': const Uuid().v4(), 'name': 'Drinks'},
        {'id': const Uuid().v4(), 'name': 'Desserts'},
      ];

      for (final cat in categories) {
        await db.into(db.localMenuCategories).insert(
          LocalMenuCategoriesCompanion.insert(
            id: cat['id']!,
            restaurantId: restaurantId,
            name: cat['name']!,
          ),
        );

        // Queue action for syncing to Supabase
        await db.into(db.offlineQueues).insert(
          OfflineQueuesCompanion.insert(
            actionType: 'INSERT',
            tableTarget: 'menu_categories',
            recordId: cat['id']!,
            payload: jsonEncode({
              'id': cat['id']!,
              'restaurant_id': restaurantId,
              'name': cat['name']!,
            }),
          ),
        );
      }

      // 3. Define Raw Ingredients
      final ingredients = [
        {'id': const Uuid().v4(), 'name': 'Beef Patty', 'qty': 80.0, 'unit': 'pcs'},
        {'id': const Uuid().v4(), 'name': 'Burger Bun', 'qty': 80.0, 'unit': 'pcs'},
        {'id': const Uuid().v4(), 'name': 'Cheese Slice', 'qty': 150.0, 'unit': 'pcs'},
        {'id': const Uuid().v4(), 'name': 'Tomato', 'qty': 15.0, 'unit': 'kg'},
        {'id': const Uuid().v4(), 'name': 'Potatoes', 'qty': 30.0, 'unit': 'kg'},
        {'id': const Uuid().v4(), 'name': 'Pizza Dough', 'qty': 50.0, 'unit': 'pcs'},
        {'id': const Uuid().v4(), 'name': 'Mozzarella', 'qty': 20.0, 'unit': 'kg'},
        {'id': const Uuid().v4(), 'name': 'Pepperoni', 'qty': 8.0, 'unit': 'kg'},
        {'id': const Uuid().v4(), 'name': 'Soda Can', 'qty': 120.0, 'unit': 'pcs'},
        {'id': const Uuid().v4(), 'name': 'Chocolate', 'qty': 10.0, 'unit': 'kg'},
      ];

      final ingMap = <String, String>{};
      for (final ing in ingredients) {
        await db.into(db.localIngredients).insert(
          LocalIngredientsCompanion.insert(
            id: ing['id'] as String,
            restaurantId: restaurantId,
            name: ing['name'] as String,
            quantity: ing['qty'] as double,
            unit: ing['unit'] as String,
          ),
        );
        ingMap[ing['name'] as String] = ing['id'] as String;
      }

      // 4. Define Menu Items
      final menuItems = [
        {
          'id': const Uuid().v4(),
          'catId': categories[0]['id'], // Burgers
          'name': 'Classic Cheeseburger',
          'price': 8.99,
          'cost': 3.50,
          'stock': 80,
          'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
          'recipe': [
            {'ingName': 'Beef Patty', 'qty': 1.0},
            {'ingName': 'Burger Bun', 'qty': 1.0},
            {'ingName': 'Cheese Slice', 'qty': 1.0},
            {'ingName': 'Tomato', 'qty': 0.05},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[0]['id'], // Burgers
          'name': 'Double Beef Burger',
          'price': 11.99,
          'cost': 5.00,
          'stock': 40,
          'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
          'recipe': [
            {'ingName': 'Beef Patty', 'qty': 2.0},
            {'ingName': 'Burger Bun', 'qty': 1.0},
            {'ingName': 'Cheese Slice', 'qty': 2.0},
            {'ingName': 'Tomato', 'qty': 0.05},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[1]['id'], // Pizzas
          'name': 'Pepperoni Pizza',
          'price': 14.99,
          'cost': 6.00,
          'stock': 50,
          'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
          'recipe': [
            {'ingName': 'Pizza Dough', 'qty': 1.0},
            {'ingName': 'Mozzarella', 'qty': 0.25},
            {'ingName': 'Pepperoni', 'qty': 0.1},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[1]['id'], // Pizzas
          'name': 'Margherita Pizza',
          'price': 12.99,
          'cost': 4.50,
          'stock': 50,
          'image': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
          'recipe': [
            {'ingName': 'Pizza Dough', 'qty': 1.0},
            {'ingName': 'Mozzarella', 'qty': 0.3},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[2]['id'], // Sides
          'name': 'Golden French Fries',
          'price': 3.99,
          'cost': 1.00,
          'stock': 120,
          'image': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500',
          'recipe': [
            {'ingName': 'Potatoes', 'qty': 0.25},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[3]['id'], // Drinks
          'name': 'Ice Cold Soda',
          'price': 1.99,
          'cost': 0.50,
          'stock': 120,
          'image': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=500',
          'recipe': [
            {'ingName': 'Soda Can', 'qty': 1.0},
          ]
        },
        {
          'id': const Uuid().v4(),
          'catId': categories[4]['id'], // Desserts
          'name': 'Chocolate Lava Cake',
          'price': 5.99,
          'cost': 2.00,
          'stock': 30,
          'image': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500',
          'recipe': [
            {'ingName': 'Chocolate', 'qty': 0.15},
          ]
        },
      ];

      for (final item in menuItems) {
        final itemId = item['id'] as String;
        await db.into(db.localMenuItems).insert(
          LocalMenuItemsCompanion.insert(
            id: itemId,
            restaurantId: restaurantId,
            categoryId: item['catId'] as String,
            name: item['name'] as String,
            price: item['price'] as double,
            costPrice: Value(item['cost'] as double),
            stockQuantity: Value(item['stock'] as int),
            imageUrl: Value(item['image'] as String),
            isDeal: const Value(false),
          ),
        );

        // Queue action for syncing to Supabase
        await db.into(db.offlineQueues).insert(
          OfflineQueuesCompanion.insert(
            actionType: 'INSERT',
            tableTarget: 'menu_items',
            recordId: itemId,
            payload: jsonEncode({
              'id': itemId,
              'restaurant_id': restaurantId,
              'category_id': item['catId'] as String,
              'name': item['name'] as String,
              'price': item['price'] as double,
              'cost_price': item['cost'] as double,
              'stock_quantity': item['stock'] as int,
              'image_url': item['image'] as String,
              'is_deal': false,
            }),
          ),
        );

        // Save recipe
        final recipeList = item['recipe'] as List<Map<String, dynamic>>;
        for (final r in recipeList) {
          final ingId = ingMap[r['ingName']];
          if (ingId != null) {
            await db.into(db.localMenuItemIngredients).insert(
              LocalMenuItemIngredientsCompanion.insert(
                menuItemId: itemId,
                ingredientId: ingId,
                quantityNeeded: r['qty'] as double,
              ),
            );
          }
        }
      }

      // 5. Define Tables
      final tables = [
        {'id': const Uuid().v4(), 'num': 'Table 1', 'cap': 2, 'status': 'available'},
        {'id': const Uuid().v4(), 'num': 'Table 2', 'cap': 4, 'status': 'available'},
        {'id': const Uuid().v4(), 'num': 'Table 3', 'cap': 4, 'status': 'occupied'},
        {'id': const Uuid().v4(), 'num': 'Table 4', 'cap': 6, 'status': 'available'},
        {'id': const Uuid().v4(), 'num': 'Table 5', 'cap': 8, 'status': 'cleaning'},
        {'id': const Uuid().v4(), 'num': 'Table 6', 'cap': 2, 'status': 'available'},
      ];

      for (final tab in tables) {
        await db.into(db.localTables).insert(
          LocalTablesCompanion.insert(
            id: tab['id'] as String,
            restaurantId: restaurantId,
            tableNumber: tab['num'] as String,
            capacity: Value(tab['cap'] as int),
            status: Value(tab['status'] as String),
          ),
        );

        // Queue action for syncing to Supabase
        await db.into(db.offlineQueues).insert(
          OfflineQueuesCompanion.insert(
            actionType: 'INSERT',
            tableTarget: 'tables',
            recordId: tab['id'] as String,
            payload: jsonEncode({
              'id': tab['id'] as String,
              'restaurant_id': restaurantId,
              'table_number': tab['num'] as String,
              'capacity': tab['cap'] as int,
              'status': tab['status'] as String,
            }),
          ),
        );
      }

      // 6. Define Operating Expenses
      final expenses = [
        {'name': 'Restaurant Rent', 'amount': 1500.00, 'cat': 'Rent', 'daysAgo': 15},
        {'name': 'Electricity Bill', 'amount': 345.50, 'cat': 'Utilities', 'daysAgo': 8},
        {'name': 'Water & Gas Bill', 'amount': 120.00, 'cat': 'Utilities', 'daysAgo': 7},
        {'name': 'Weekly Staff Salaries', 'amount': 950.00, 'cat': 'Salaries', 'daysAgo': 5},
        {'name': 'Meat Procurement', 'amount': 250.00, 'cat': 'InventoryRestock', 'daysAgo': 12},
        {'name': 'Soda Restocking', 'amount': 60.00, 'cat': 'InventoryRestock', 'daysAgo': 10},
      ];

      for (final exp in expenses) {
        await db.into(db.localExpenses).insert(
          LocalExpensesCompanion.insert(
            id: const Uuid().v4(),
            restaurantId: restaurantId,
            name: exp['name'] as String,
            amount: exp['amount'] as double,
            category: exp['cat'] as String,
            date: DateTime.now().subtract(Duration(days: exp['daysAgo'] as int)),
          ),
        );
      }

      // 7. Define Restock logs
      final restockLogs = [
        {'item': 'Beef Patty', 'qty': 80.0, 'unit': 'pcs', 'cost': 250.0, 'daysAgo': 12},
        {'item': 'Soda Can', 'qty': 120.0, 'unit': 'pcs', 'cost': 60.0, 'daysAgo': 10},
      ];

      for (final log in restockLogs) {
        await db.into(db.localInventoryLogs).insert(
          LocalInventoryLogsCompanion.insert(
            id: const Uuid().v4(),
            restaurantId: restaurantId,
            itemName: log['item'] as String,
            quantity: log['qty'] as double,
            unit: log['unit'] as String,
            cost: log['cost'] as double,
            date: DateTime.now().subtract(Duration(days: log['daysAgo'] as int)),
          ),
        );
      }

      // 8. Define Completed Sales Orders over the last 7 days (to populate live dashboard charts)
      final rand = Random();
      // Past 7 days sales data
      for (int day = 6; day >= 0; day--) {
        final date = DateTime.now().subtract(Duration(days: day));
        // Generate 2 to 5 orders per day
        final ordersCount = 2 + rand.nextInt(4);
        for (int o = 0; o < ordersCount; o++) {
          // Randomly pick menu items to buy
          final purchasedItems = <Map<String, dynamic>>[];
          final itemCount = 1 + rand.nextInt(3);
          double subtotal = 0.0;

          for (int i = 0; i < itemCount; i++) {
            final randItem = menuItems[rand.nextInt(menuItems.length)];
            final qty = 1 + rand.nextInt(2);
            final price = randItem['price'] as double;
            final cost = randItem['cost'] as double;

            purchasedItems.add({
              'itemId': randItem['id'],
              'qty': qty,
              'price': price,
              'cost': cost,
            });
            subtotal += price * qty;
          }

          final tax = subtotal * 0.18; // 18% tax
          final total = subtotal + tax;

          final orderId = const Uuid().v4();
          await db.into(db.localOrders).insert(
            LocalOrdersCompanion.insert(
              id: orderId,
              restaurantId: restaurantId,
              tableId: Value(tables[rand.nextInt(tables.length)]['id'] as String),
              userId: userId,
              orderType: ['dine_in', 'takeaway'][rand.nextInt(2)],
              status: 'completed',
              paymentStatus: 'paid',
              paymentMethod: Value(['Cash', 'Card'][rand.nextInt(2)]),
              subtotal: subtotal,
              tax: tax,
              discount: const Value(0.0),
              deliveryFee: const Value(0.0),
              total: total,
              createdAt: date.subtract(Duration(hours: rand.nextInt(6), minutes: rand.nextInt(60))),
            ),
          );

          // Insert items
          for (final pItem in purchasedItems) {
            await db.into(db.localOrderItems).insert(
              LocalOrderItemsCompanion.insert(
                id: const Uuid().v4(),
                orderId: orderId,
                menuItemId: pItem['itemId'] as String,
                quantity: pItem['qty'] as int,
                price: pItem['price'] as double,
                costPrice: Value(pItem['cost'] as double),
              ),
            );
          }
        }
      }

      // 9. Add 1 Active Preparing Order (so Kitchen Screen shows something in progress!)
      final prepOrderId = const Uuid().v4();
      final burgerItem = menuItems[0]; // cheeseburger
      final friesItem = menuItems[4]; // fries
      final prepSubtotal = (burgerItem['price'] as double) + (friesItem['price'] as double);
      final prepTax = prepSubtotal * 0.18;
      final prepTotal = prepSubtotal + prepTax;

      await db.into(db.localOrders).insert(
        LocalOrdersCompanion.insert(
          id: prepOrderId,
          restaurantId: restaurantId,
          tableId: Value(tables[2]['id'] as String), // Table 3 (occupied)
          userId: userId,
          orderType: 'dine_in',
          status: 'preparing',
          paymentStatus: 'unpaid',
          subtotal: prepSubtotal,
          tax: prepTax,
          discount: const Value(0.0),
          deliveryFee: const Value(0.0),
          total: prepTotal,
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
      );

      await db.into(db.localOrderItems).insert(
        LocalOrderItemsCompanion.insert(
          id: const Uuid().v4(),
          orderId: prepOrderId,
          menuItemId: burgerItem['id'] as String,
          quantity: 1,
          price: burgerItem['price'] as double,
          costPrice: Value(burgerItem['cost'] as double),
        ),
      );

      await db.into(db.localOrderItems).insert(
        LocalOrderItemsCompanion.insert(
          id: const Uuid().v4(),
          orderId: prepOrderId,
          menuItemId: friesItem['id'] as String,
          quantity: 1,
          price: friesItem['price'] as double,
          costPrice: Value(friesItem['cost'] as double),
        ),
      );

      // 10. Add 1 Draft/Open Bill Order
      final draftOrderId = const Uuid().v4();
      final pizzaItem = menuItems[2]; // pepperoni pizza
      final drinkItem = menuItems[5]; // soda
      final draftSubtotal = (pizzaItem['price'] as double) + (drinkItem['price'] as double);
      final draftTax = draftSubtotal * 0.18;
      final draftTotal = draftSubtotal + draftTax;

      await db.into(db.localOrders).insert(
        LocalOrdersCompanion.insert(
          id: draftOrderId,
          restaurantId: restaurantId,
          tableId: Value(tables[4]['id'] as String), // Table 5 (cleaning/occupied draft)
          userId: userId,
          orderType: 'dine_in',
          status: 'draft',
          paymentStatus: 'unpaid',
          subtotal: draftSubtotal,
          tax: draftTax,
          discount: const Value(0.0),
          deliveryFee: const Value(0.0),
          total: draftTotal,
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
      );

      await db.into(db.localOrderItems).insert(
        LocalOrderItemsCompanion.insert(
          id: const Uuid().v4(),
          orderId: draftOrderId,
          menuItemId: pizzaItem['id'] as String,
          quantity: 1,
          price: pizzaItem['price'] as double,
          costPrice: Value(pizzaItem['cost'] as double),
        ),
      );

      await db.into(db.localOrderItems).insert(
        LocalOrderItemsCompanion.insert(
          id: const Uuid().v4(),
          orderId: draftOrderId,
          menuItemId: drinkItem['id'] as String,
          quantity: 1,
          price: drinkItem['price'] as double,
          costPrice: Value(drinkItem['cost'] as double),
        ),
      );
    });

    print('Seeding completed successfully!');
  }
}
