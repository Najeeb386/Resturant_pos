import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final db = await WasmDatabase.open(
      databaseName: 'resturant_pos_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    if (db.missingFeatures.isNotEmpty) {
      print('Using ${db.chosenImplementation} due to missing browser features: ${db.missingFeatures}');
    }
    return db.resolvedExecutor;
  }));
}
