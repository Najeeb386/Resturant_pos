import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/views/auth/login_view.dart';
import 'package:resturant_pos_app/views/auth/register_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121214), // Carbon Slate Black
              Color(0xFF1C1917), // Stone Grey
              Color(0xFF2E1A05), // Dark Warm Chocolate Orange Tint
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo & Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF9E22),
                            Color(0xFFF97316),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.point_of_sale_outlined,
                            color: Color(0xFFF97316),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Dine Desk POS',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                
                // Hero Text
                Text(
                  'The Complete Restaurant Management Platform',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: isTablet ? 36 : 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Empower your restaurant with online/offline point of sale, kitchen screens, real-time inventory management, procurement logs, expense tracking, and custom reports. Entirely free.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF94A3B8), // Slate 400
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Core Action Buttons
                SizedBox(
                  width: isTablet ? 400 : double.infinity,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/LoginView'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: const Text('Log In to Restaurant'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Get.toNamed('/SelectPlanView'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38, width: 1.5),
                        ),
                        child: const Text('Create New Restaurant (Free SaaS Trial)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // Features Grid
                Text(
                  'Explore Key Features',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.wifi_off_outlined,
                      title: 'Offline First',
                      desc: 'Full POS functionality without internet. Automatically syncs changes when online.',
                      isTablet: isTablet,
                    ),
                    _buildFeatureCard(
                      icon: Icons.kitchen_outlined,
                      title: 'Kitchen Display',
                      desc: 'Real-time kitchen order list. Instantly routes checkouts to cooking staff.',
                      isTablet: isTablet,
                    ),
                    _buildFeatureCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory & Recipe',
                      desc: 'Compound recipe stock tracking. Automatically deducts ingredients during checkout.',
                      isTablet: isTablet,
                    ),
                    _buildFeatureCard(
                      icon: Icons.pie_chart_outline_outlined,
                      title: 'Analytics & Reports',
                      desc: 'Interactive sales charts, COGS margins, operating costs, and profit reports.',
                      isTablet: isTablet,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isTablet,
  }) {
    return Container(
      width: isTablet ? 320 : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF262626).withOpacity(0.5), // Charcoal Grey
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF404040), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 30),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
