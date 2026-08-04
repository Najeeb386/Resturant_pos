import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/app_provider.dart';
import 'main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController(text: 'owner@restaurant.com');
  final _passwordController = TextEditingController(text: 'password');
  final _urlController = TextEditingController(text: ApiService.baseUrl);

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 64), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  'DineDesk POS',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Offline-First Restaurant Terminal',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),

                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Server API URL',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _loading ? null : _handleLogin,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login to Terminal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.saveBaseUrl(_urlController.text.trim());
      await ApiService.login(_emailController.text.trim(), _passwordController.text.trim());
      
      if (mounted) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        await provider.refreshFromApi();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainView()));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
