import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resturant_pos_app/core/theme/app_theme.dart';
import 'package:resturant_pos_app/providers/auth_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  
  // 1: Request OTP, 2: Verify OTP, 3: Reset Password
  int _currentStep = 1; 

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtpCode() async {
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      Get.snackbar(
        'Required', 
        'Please enter a valid email address',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authProvider.sendOtp(_emailController.text.trim());
    if (success) {
      Get.snackbar(
        'Success', 
        'OTP code sent to ${_emailController.text.trim()}',
        backgroundColor: AppTheme.accentEmerald,
        colorText: Colors.white,
      );
      setState(() {
        _currentStep = 2;
      });
    } else {
      _showError(authProvider.state.value.error ?? 'Failed to send OTP code');
    }
  }

  void _verifyOtpCode() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      Get.snackbar(
        'Required', 
        'Please enter the 6-digit OTP code',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authProvider.verifyOtp(_emailController.text.trim(), code);
    if (success) {
      Get.snackbar(
        'Success', 
        'OTP code verified successfully',
        backgroundColor: AppTheme.accentEmerald,
        colorText: Colors.white,
      );
      setState(() {
        _currentStep = 3;
      });
    } else {
      _showError(authProvider.state.value.error ?? 'Invalid OTP code. Please try again.');
    }
  }

  void _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newPass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;
    
    if (newPass != confirmPass) {
      Get.snackbar(
        'Mismatch', 
        'Passwords do not match',
        backgroundColor: AppTheme.accentRose,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authProvider.updateForgottenPassword(
      _emailController.text.trim(),
      newPass,
    );
    if (success) {
      Get.defaultDialog(
        title: 'Success',
        middleText: 'Your password has been reset successfully. Please log in with your new password.',
        confirm: ElevatedButton(
          onPressed: () {
            Get.back(); // close dialog
            Get.offAllNamed('/LoginView');
          },
          child: const Text('Log In'),
        ),
      );
    } else {
      _showError(authProvider.state.value.error ?? 'Failed to reset password');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error', 
      message,
      backgroundColor: AppTheme.accentRose,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = authProvider.state.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() {
                _currentStep--;
              });
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              color: const Color(0xFF1E293B), // Slate 800
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getStepIcon(),
                            color: AppTheme.primaryLight,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Heading Title
                      Text(
                        _getStepTitle(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Step Indicator text
                      Text(
                        'Step $_currentStep of 3: ${_getStepDescription()}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Dynamic Fields rendering
                      if (_currentStep == 1) ...[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Registered Email',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _sendOtpCode,
                          child: authState.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Send OTP Code'),
                        ),
                      ] else if (_currentStep == 2) ...[
                        Text(
                          'We have sent a verification code to: ${_emailController.text}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black),
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: '6-Digit Verification OTP',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.password_outlined, color: Color(0xFF64748B)),
                            counterStyle: TextStyle(color: Color(0xFF64748B)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _verifyOtpCode,
                          child: authState.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Verify & Proceed'),
                        ),
                      ] else if (_currentStep == 3) ...[
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.lock_reset, color: Color(0xFF64748B)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Password',
                            labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF475569))),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirm Password is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _updatePassword,
                          child: authState.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Update Password'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStepIcon() {
    if (_currentStep == 1) return Icons.mark_email_read_outlined;
    if (_currentStep == 2) return Icons.vpn_key_outlined;
    return Icons.lock_open_outlined;
  }

  String _getStepTitle() {
    if (_currentStep == 1) return 'Forgot Password';
    if (_currentStep == 2) return 'Enter OTP';
    return 'Reset Password';
  }

  String _getStepDescription() {
    if (_currentStep == 1) return 'Request OTP Code';
    if (_currentStep == 2) return 'Verify OTP Verification Code';
    return 'Enter your new workspace password';
  }
}
