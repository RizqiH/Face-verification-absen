import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/user/user_bloc.dart';

/// Refactored Edit Profile Page
class EditProfilePageRefactored extends StatefulWidget {
  const EditProfilePageRefactored({super.key});

  @override
  State<EditProfilePageRefactored> createState() =>
      _EditProfilePageRefactoredState();
}

class _EditProfilePageRefactoredState extends State<EditProfilePageRefactored> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _nameController = TextEditingController(text: user.name);
      _positionController = TextEditingController(text: user.position);
      _departmentController = TextEditingController(text: user.department);
    } else {
      _nameController = TextEditingController();
      _positionController = TextEditingController();
      _departmentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
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
                _buildNameField(),
                const SizedBox(height: 20),
                _buildPositionField(),
                const SizedBox(height: 20),
                _buildDepartmentField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
        ),
      ),
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

  Widget _buildPositionField() {
    return CustomTextField(
      controller: _positionController,
      labelText: 'Posisi',
      hintText: 'Masukkan posisi',
      prefixIcon: Icons.work_outlined,
      validator: (value) => Validators.required(value, fieldName: 'Posisi'),
    );
  }

  Widget _buildDepartmentField() {
    return CustomTextField(
      controller: _departmentController,
      labelText: 'Departemen',
      hintText: 'Masukkan departemen',
      prefixIcon: Icons.business_outlined,
      validator: (value) => Validators.required(value, fieldName: 'Departemen'),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Simpan Perubahan',
          onPressed: _handleSave,
          isLoading: state is UserLoading,
          fullWidth: true,
        );
      },
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
            UpdateProfileEvent(
              name: _nameController.text.trim(),
              position: _positionController.text.trim(),
              department: _departmentController.text.trim(),
            ),
          );
    }
  }
}

