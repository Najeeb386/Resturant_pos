import 'package:drift/drift.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';

class BackupHelper {
  static Future<String> generateSqlDump(AppDatabase db, {String? restaurantId}) async {
    final buffer = StringBuffer();
    buffer.writeln('-- Restaurant POS Database Backup');
    buffer.writeln('-- Generated at: ${DateTime.now().toUtc().toIso8601String()} UTC');
    if (restaurantId != null) {
      buffer.writeln('-- Scope: Restaurant ID = $restaurantId');
    } else {
      buffer.writeln('-- Scope: Global (All Restaurants)');
    }
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln();

    try {
      // 1. Fetch schema creation statements for all tables
      final schemaRows = await db.customSelect(
        "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata'"
      ).get();

      for (final sRow in schemaRows) {
        final tableName = sRow.read<String>('name');
        final tableSql = sRow.read<String>('sql');
        
        buffer.writeln('-- Schema for table: $tableName');
        buffer.writeln('DROP TABLE IF EXISTS `$tableName`;');
        buffer.writeln('$tableSql;');
        buffer.writeln();
      }

      // Pre-fetch related IDs to filter join/child tables for a specific restaurant
      List<String> validMenuItemIds = [];
      List<String> validOrderIds = [];

      if (restaurantId != null) {
        final menuItems = await (db.select(db.localMenuItems)..where((t) => t.restaurantId.equals(restaurantId))).get();
        validMenuItemIds = menuItems.map((m) => m.id).toList();

        final orders = await (db.select(db.localOrders)..where((t) => t.restaurantId.equals(restaurantId))).get();
        validOrderIds = orders.map((o) => o.id).toList();
      }

      // 2. Fetch data rows and generate INSERT statements for each table
      for (final table in db.allTables) {
        final tableName = table.actualTableName;
        final query = db.select(table);

        // Apply filters if restaurantId is specified
        if (restaurantId != null) {
          if (tableName == 'local_restaurants') {
            query.where((t) => (t as LocalRestaurants).id.equals(restaurantId));
          } else if (tableName == 'local_users') {
            query.where((t) => (t as LocalUsers).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_tables') {
            query.where((t) => (t as LocalTables).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_menu_categories') {
            query.where((t) => (t as LocalMenuCategories).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_menu_items') {
            query.where((t) => (t as LocalMenuItems).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_ingredients') {
            query.where((t) => (t as LocalIngredients).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_orders') {
            query.where((t) => (t as LocalOrders).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_expenses') {
            query.where((t) => (t as LocalExpenses).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_inventory_logs') {
            query.where((t) => (t as LocalInventoryLogs).restaurantId.equals(restaurantId));
          } else if (tableName == 'local_menu_item_ingredients') {
            query.where((t) => (t as LocalMenuItemIngredients).menuItemId.isIn(validMenuItemIds));
          } else if (tableName == 'local_deal_items') {
            query.where((t) => (t as LocalDealItems).dealItemId.isIn(validMenuItemIds));
          } else if (tableName == 'local_order_items') {
            query.where((t) => (t as LocalOrderItems).orderId.isIn(validOrderIds));
          }
        }

        final rows = await query.get();
        if (rows.isEmpty) continue;

        buffer.writeln('-- Data for table: $tableName');
        for (final row in rows) {
          final columnsMap = (row as Insertable).toColumns(false);
          final keys = columnsMap.keys.toList();
          final values = keys.map((key) {
            final expr = columnsMap[key];
            dynamic val;
            if (expr is Variable) {
              val = expr.value;
            } else if (expr is Constant) {
              val = expr.value;
            } else {
              val = expr;
            }

            if (val == null) {
              return 'NULL';
            } else if (val is String) {
              final escaped = val.replaceAll("'", "''");
              return "'$escaped'";
            } else if (val is DateTime) {
              return "'${val.toIso8601String()}'";
            } else if (val is bool) {
              return val ? '1' : '0';
            } else {
              return val.toString();
            }
          }).toList();

          buffer.writeln(
            "INSERT INTO `$tableName` (${keys.map((k) => '`$k`').join(', ')}) VALUES (${values.join(', ')});"
          );
        }
        buffer.writeln();
      }

      buffer.writeln('PRAGMA foreign_keys=ON;');
      return buffer.toString();
    } catch (e) {
      throw Exception('SQL Backup generation failed: $e');
    }
  }
}
