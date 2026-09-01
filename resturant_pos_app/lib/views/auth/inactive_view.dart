import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';

class InactiveView extends StatelessWidget {
  const InactiveView({super.key});

  @override
  Widget build(BuildContext context) {
    const contactNumber = '03272352752';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Warning Glow Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentRose.withOpacity(0.2), width: 2),
                    ),
                    child: const Icon(
                      Icons.gpp_bad_outlined,
                      color: AppTheme.accentRose,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Header
                Text(
                  'Workspace Suspended',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Body message
                Text(
                  'Your restaurant account is inactive or suspended. Kindly contact the service provider to reactivate access to your POS workspace.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8), // Slate 400
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Contact Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Slate 800
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SERVICE PROVIDER HELPLINE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_in_talk, color: AppTheme.primaryLight, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            contactNumber,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: contactNumber));
                          Get.snackbar(
                            'Copied',
                            'Helpline number copied to clipboard',
                            backgroundColor: AppTheme.accentEmerald,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16, color: Colors.black87),
                        label: const Text('Copy Number'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          minimumSize: const Size(120, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Logout/Back to Login
                OutlinedButton(
                  onPressed: () async {
                    await authProvider.logout();
                    Get.offAllNamed('/');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
