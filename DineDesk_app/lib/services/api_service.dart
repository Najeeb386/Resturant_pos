import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      return 'http://10.0.2.2:8000/api/v1';
    }
  }

  static String baseUrl = defaultBaseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', url);
    baseUrl = url;
  }

  static Future<void> initUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('base_url');
    if (savedUrl != null && savedUrl.isNotEmpty && (!kIsWeb || !savedUrl.contains('10.0.2.2'))) {
      baseUrl = savedUrl;
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
}
