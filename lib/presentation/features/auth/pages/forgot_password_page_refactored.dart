import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';

/// Refactored Forgot Password Page
class ForgotPasswordPageRefactored extends StatefulWidget {
  const ForgotPasswordPageRefactored({super.key});

  @override
  State<ForgotPasswordPageRefactored> createState() =>
      _ForgotPasswordPageRefactoredState();
}

class _ForgotPasswordPageRefactoredState
    extends State<ForgotPasswordPageRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 32),
              _buildResetButton(),
              const SizedBox(height: 24),
              _buildBackToLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 50,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Masukkan email Anda untuk menerima link reset password',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return EmailTextField(
      controller: _emailController,
      validator: Validators.email,
    );
  }

  Widget _buildResetButton() {
    return CustomButton(
      text: 'Kirim Link Reset',
      onPressed: _handleResetPassword,
      isLoading: _isLoading,
      fullWidth: true,
    );
  }

  Widget _buildBackToLogin() {
    return TextButton(
      onPressed: () => context.go(AppRoutes.login),
      child: const Text(
        'Kembali ke Login',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Link reset password telah dikirim ke email Anda')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Navigate back to login after showing toast
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppRoutes.login);
        }
      });
    }
  }
}

