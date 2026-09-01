import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile(String fileName, String content) async {
  final bytes = utf8.encode(content);
  final tempDir = await getTemporaryDirectory();
  final file = io.File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Restaurant POS SQL Database Backup',
    subject: 'Database Backup',
  );
}
