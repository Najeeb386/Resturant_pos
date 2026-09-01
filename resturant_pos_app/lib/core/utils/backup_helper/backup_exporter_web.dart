import 'dart:convert';
import 'dart:html' as html;

Future<void> saveAndShareFile(String fileName, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/sql');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
