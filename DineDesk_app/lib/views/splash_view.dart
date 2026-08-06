import 'package:flutter/material.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 110,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu, size: 64, color: Colors.deepOrange),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DineDesk POS',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Smart Restaurant Terminal & Point of Sale',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.deepOrange,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
