import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_db_service.dart';
import 'api_service.dart';
import '../models/models.dart';

enum SyncStatus { online, offline, syncing }

class SyncService {
  final LocalDbService _dbService = LocalDbService();
  SyncStatus _status = SyncStatus.online;
  int _pendingCount = 0;

  SyncStatus get status => _status;
  int get pendingCount => _pendingCount;

  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  void initNetworkListener(Function onStatusChanged) {
    Connectivity().onConnectivityChanged.listen((results) async {
      bool isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        _status = SyncStatus.syncing;
        onStatusChanged();
        await autoSyncPendingOrders();
        _status = SyncStatus.online;
      } else {
        _status = SyncStatus.offline;
      }
      await updatePendingCount();
      onStatusChanged();
    });
  }

  Future<void> updatePendingCount() async {
    List<OrderModel> unsynced = await _dbService.getUnsyncedOrders();
    _pendingCount = unsynced.length;
  }

  Future<bool> autoSyncPendingOrders() async {
    try {
      List<OrderModel> unsynced = await _dbService.getUnsyncedOrders();
      if (unsynced.isEmpty) {
        _pendingCount = 0;
        return true;
      }

      List<Map<String, dynamic>> payload = unsynced.map((o) => o.toJson()).toList();
      var response = await ApiService.syncOfflineOrders(payload);

      if (response['success'] == true) {
        List<String> syncedIds = unsynced.map((o) => o.localId).toList();
        await _dbService.markOrdersAsSynced(syncedIds);
        _pendingCount = 0;
        return true;
      }
      return false;
    } catch (e) {
      print('Auto Sync Error: $e');
      return false;
    }
  }
}
