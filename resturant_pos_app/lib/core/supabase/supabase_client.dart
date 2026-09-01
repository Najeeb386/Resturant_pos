import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  // Placeholders for Supabase credentials. 
  // The user can create a free project at supabase.com and paste their credentials here.
  static const String supabaseUrl = 'https://jenduqrmczhlhmaxzgxw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplbmR1cXJtY3pobGhtYXh6Z3h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0OTU2MjcsImV4cCI6MjA5ODA3MTYyN30.75dUG7Sj1zHpYEgqJXO0K5GCiCKB70iY1tajKg0eZLw';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          pkceAsyncStorage: SharedPreferencesAsyncStorage(),
        ),
      );
    } catch (e) {
      // If credentials are placeholder, catch error silently so the app can run offline
      print('Supabase initialization failed: $e');
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  // Auth Operations
  Future<AuthResponse> login(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<String?> uploadLogo(String fileName, Uint8List fileBytes, {String? oldLogoUrl}) async {
    try {
      final supa = client;

      // Delete old logo if it exists in storage bucket
      if (oldLogoUrl != null && oldLogoUrl.trim().isNotEmpty) {
        try {
          final uri = Uri.parse(oldLogoUrl);
          final oldFileName = uri.pathSegments.last;
          if (oldFileName.isNotEmpty) {
            await supa.storage.from('logos').remove([oldFileName]);
            print('Successfully deleted old logo from Supabase: $oldFileName');
          }
        } catch (err) {
          print('Error removing old logo: $err');
        }
      }

      final fileExtension = fileName.split('.').last;
      final uniquePath = 'logo_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await supa.storage.from('logos').uploadBinary(
        uniquePath,
        fileBytes,
        fileOptions: const FileOptions(
          contentType: 'image/*',
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = supa.storage.from('logos').getPublicUrl(uniquePath);
      return publicUrl;
    } catch (e) {
      print('Supabase Storage Error: $e');
      throw Exception('$e');
    }
  }
}

class SharedPreferencesAsyncStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> removeItem({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
