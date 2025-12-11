import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../bloc/auth/auth_bloc.dart';

/// Refactored Register Page with modern architecture
class RegisterPageRefactored extends StatefulWidget {
  const RegisterPageRefactored({super.key});

  @override
  State<RegisterPageRefactored> createState() => _RegisterPageRefactoredState();
}

class _RegisterPageRefactoredState extends State<RegisterPageRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _employeeIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('Registrasi berhasil!')),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              context.go(AppRoutes.login);
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 32),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmployeeIdField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Akun',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Buat akun baru untuk mulai',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      labelText: 'Nama Lengkap',
      hintText: 'Masukkan nama lengkap',
      prefixIcon: Icons.person_outlined,
      validator: Validators.name,
    );
  }

  Widget _buildEmployeeIdField() {
    return CustomTextField(
      controller: _employeeIdController,
      labelText: 'Employee ID',
      hintText: 'Masukkan Employee ID',
      prefixIcon: Icons.badge_outlined,
      validator: Validators.employeeId,
    );
  }

  Widget _buildEmailField() {
    return EmailTextField(
      controller: _emailController,
      validator: Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return PasswordTextField(
      controller: _passwordController,
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return PasswordTextField(
      controller: _confirmPasswordController,
      labelText: 'Konfirmasi Password',
      hintText: 'Masukkan ulang password',
      validator: (value) => Validators.match(
        value,
        _passwordController.text,
        'Password',
      ),
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Daftar',
          onPressed: _handleRegister,
          isLoading: state is AuthLoading,
          fullWidth: true,
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Sudah punya akun? ',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterEvent(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              employeeId: _employeeIdController.text.trim(),
            ),
          );
    }
  }
}

