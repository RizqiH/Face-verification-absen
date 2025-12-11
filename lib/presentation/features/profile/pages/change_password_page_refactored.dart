import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../bloc/user/user_bloc.dart';

/// Refactored Change Password Page
class ChangePasswordPageRefactored extends StatefulWidget {
  const ChangePasswordPageRefactored({super.key});

  @override
  State<ChangePasswordPageRefactored> createState() =>
      _ChangePasswordPageRefactoredState();
}

class _ChangePasswordPageRefactoredState
    extends State<ChangePasswordPageRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop();
          }
        },
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
          if (state is UserSuccess) {
            // Show success toast
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
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
            // Navigate back after showing toast
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is UserError) {
            // Show error toast
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
                _buildLockIcon(),
                const SizedBox(height: 32),
                _buildCurrentPasswordField(),
                const SizedBox(height: 20),
                _buildNewPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 32),
                _buildChangeButton(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_outline,
        size: 40,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildCurrentPasswordField() {
    return PasswordTextField(
      controller: _currentPasswordController,
      labelText: 'Password Saat Ini',
      hintText: 'Masukkan password saat ini',
      validator: Validators.password,
    );
  }

  Widget _buildNewPasswordField() {
    return PasswordTextField(
      controller: _newPasswordController,
      labelText: 'Password Baru',
      hintText: 'Masukkan password baru',
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return PasswordTextField(
      controller: _confirmPasswordController,
      labelText: 'Konfirmasi Password Baru',
      hintText: 'Masukkan ulang password baru',
      validator: (value) => Validators.match(
        value,
        _newPasswordController.text,
        'Password',
      ),
    );
  }

  Widget _buildChangeButton() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Ubah Password',
          onPressed: _handleChangePassword,
          isLoading: state is UserLoading,
          fullWidth: true,
        );
      },
    );
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
            ChangePasswordEvent(
              oldPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }
}

