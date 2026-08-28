import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get defaultBaseUrl {
    return 'https://dinedesk.thezerobug.com/api/v1';
  }

  static String baseUrl = defaultBaseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  static Future<void> saveBaseUrl(String url) async {
    String cleanUrl = url.trim();
    while (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', cleanUrl);
    baseUrl = cleanUrl;
  }

  static Future<void> initUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('base_url');
    if (savedUrl != null && savedUrl.isNotEmpty && (!kIsWeb || !savedUrl.contains('10.0.2.2'))) {
      String cleanUrl = savedUrl.trim();
      while (cleanUrl.endsWith('/')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      baseUrl = cleanUrl;
    } else {
      baseUrl = defaultBaseUrl;
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await initUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> fetchBootstrapData() async {
    await initUrl();
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/bootstrap'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch bootstrap data: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> syncOfflineOrders(List<Map<String, dynamic>> ordersJson) async {
    await initUrl();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/sync/orders'),
      headers: headers,
      body: jsonEncode({'orders': ordersJson}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Order sync failed: ${response.body}');
    }
  }

  static Future<bool> updateOrderStatus(int serverId, String status, {String? paymentStatus}) async {
    try {
      await initUrl();
      final headers = await getHeaders();
      final body = <String, dynamic>{'status': status};
      if (paymentStatus != null) body['payment_status'] = paymentStatus;

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$serverId/status'),
        headers: headers,
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update status error: $e');
      return false;
    }
  }

  static Future<bool> confirmOrderUpdate(int serverId) async {
    try {
      await initUrl();
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$serverId/confirm-update'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Confirm update error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> createTable(String tableNumber, int capacity) async {
    await initUrl();
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/tables'),
      headers: headers,
      body: jsonEncode({
        'table_number': tableNumber,
        'capacity': capacity,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create table: ${response.body}');
    }
  }

  static Future<bool> updateTable(int id, {String? tableNumber, int? capacity, String? status}) async {
    try {
      await initUrl();
      final headers = await getHeaders();
      final body = <String, dynamic>{};
      if (tableNumber != null) body['table_number'] = tableNumber;
      if (capacity != null) body['capacity'] = capacity;
      if (status != null) body['status'] = status;

      final response = await http.patch(
        Uri.parse('$baseUrl/tables/$id'),
        headers: headers,
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update table error: $e');
      return false;
    }
  }

  static Future<bool> deleteTable(int id) async {
    try {
      await initUrl();
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/tables/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete table error: $e');
      return false;
    }
  }
}
