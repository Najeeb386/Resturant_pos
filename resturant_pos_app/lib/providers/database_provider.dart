import 'package:get/get.dart';
import 'package:resturant_pos_app/core/database/local_database.dart';
import 'package:resturant_pos_app/core/sync/sync_manager.dart';

class DatabaseController extends GetxController {
  late final AppDatabase db;
  late final SyncManager syncManager;

  @override
  void onInit() {
    super.onInit();
    db = AppDatabase();
    syncManager = SyncManager(db);
  }

  @override
  void onClose() {
    db.close();
    super.onClose();
  }
}

// Helpers for backward compatibility and clean access
AppDatabase get databaseProvider => Get.find<DatabaseController>().db;
SyncManager get syncManagerProvider => Get.find<DatabaseController>().syncManager;
