import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';

import 'package:resturant_pos_app/views/dashboard/navigation_shell.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final args = Get.arguments as Map<String, dynamic>?;
      final selectedPlan = args?['selectedPlan'] ?? 'Premium';

      final success = await authProvider.registerRestaurant(
        restaurantName: _restaurantNameController.text.trim(),
        adminName: _adminNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        selectedPlan: selectedPlan,
      );
      if (success) {
        Get.offAll(() => const NavigationShell());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Obx(() {
                final authState = authProvider.state.value;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.business_outlined,
                          color: AppTheme.primaryDark,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Register Restaurant',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your multi-tenant SaaS workspace',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final args = Get.arguments as Map<String, dynamic>?;
                        final selectedPlan = args?['selectedPlan'] ?? 'Premium';
                        Color badgeColor = AppTheme.primaryLight;
                        if (selectedPlan.toString().toLowerCase() == 'standard') {
                          badgeColor = AppTheme.accentTeal;
                        } else if (selectedPlan.toString().toLowerCase() == 'premium') {
                          badgeColor = AppTheme.accentEmerald;
                        }

                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: badgeColor.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_outline, size: 16, color: badgeColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Plan: $selectedPlan (30-Day Free Trial)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 36),

                    if (authState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentRose.withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppTheme.accentRose,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Restaurant Name
                    TextFormField(
                      controller: _restaurantNameController,
                      decoration: const InputDecoration(
                        labelText: 'Restaurant Name',
                        prefixIcon: Icon(Icons.store_outlined, color: Color(0xFF94A3B8)),
                        hintText: 'e.g. Tasty Station',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Restaurant name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Admin Name
                    TextFormField(
                      controller: _adminNameController,
                      decoration: const InputDecoration(
                        labelText: 'Admin Full Name',
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                        hintText: 'e.g. John Doe',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Admin name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Admin Email',
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                        hintText: 'e.g. admin@dinedesk.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFF94A3B8)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 8) return 'Password must be at least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create Restaurant Workspace'),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
