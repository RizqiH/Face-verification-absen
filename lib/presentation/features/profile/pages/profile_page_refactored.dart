import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/toast_notification.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/user/user_bloc.dart';
import '../widgets/profile_menu_item.dart';

/// Refactored Profile Page
class ProfilePageRefactored extends StatelessWidget {
  const ProfilePageRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserSuccess) {
            LoadingOverlay.hide(context);
            ToastNotification.success(context, state.message);
          } else if (state is UserError) {
            LoadingOverlay.hide(context);
            ToastNotification.error(context, state.message);
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) {
                // Always rebuild when state type changes
                if (previous.runtimeType != current.runtimeType) return true;
                
                // Rebuild when user data changes (especially profilePhotoUrl)
                if (previous is AuthAuthenticated && current is AuthAuthenticated) {
                  // Rebuild if profile photo URL changes
                  return previous.user.profilePhotoUrl != current.user.profilePhotoUrl ||
                         previous.user.name != current.user.name ||
                         previous.user.position != current.user.position;
                }
                
                return false;
              },
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  // Prevent back button from exiting app
                  // Since this is inside HomePageWithNav, back button should do nothing
                  // or navigate within the app
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildProfileHeader(context, state.user),
                      const SizedBox(height: 24),
                      _buildMenuSection(context),
                      SizedBox(height: 80 + bottomPadding), // Dynamic padding for bottom nav
                    ],
                  ),
                ),
              );
              }
              return const Center(child: CircularProgressIndicator());
            },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: (user.profilePhotoUrl != null &&
                          user.profilePhotoUrl!.isNotEmpty)
                      ? GestureDetector(
                          onTap: () => _showPhotoPreview(context, user.profilePhotoUrl!),
                          child: Image.network(
                            user.profilePhotoUrl!,
                            key: ValueKey('profile_${user.profilePhotoUrl}'), // Only rebuild when URL actually changes
                            width: 100, // Explicit width
                            height: 100, // Explicit height - SQUARE to prevent gepeng
                            fit: BoxFit.cover, // Cover maintains aspect ratio, crops if needed
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 300),
                                child: child,
                              );
                            },
                            cacheWidth: 200, // Optimize image loading (100px * 2 for retina)
                            cacheHeight: 200, // SAME ratio to prevent distortion
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    size: 50, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showChangePhotoDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.position,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.edit,
            title: 'Edit Profil',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          const Divider(height: 1, thickness: 1, indent: 56),
          ProfileMenuItem(
            icon: Icons.lock,
            title: 'Ubah Password',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          const Divider(height: 1, thickness: 1, indent: 56),
          ProfileMenuItem(
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () => context.push(AppRoutes.settings),
          ),
          const Divider(height: 1, thickness: 1, indent: 56),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            titleColor: Colors.red,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _showChangePhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Foto Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto dengan Kamera'),
              subtitle: const Text('Rekomendasi: gunakan panduan wajah'),
              onTap: () {
                Navigator.pop(dialogContext);
                _openCameraWithGuide(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickAndUploadImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCameraWithGuide(BuildContext context) async {
    try {
      // Navigate to camera page with face guide
      final photoPath = await context.push<String>(AppRoutes.cameraProfile);
      
      if (photoPath != null && photoPath.isNotEmpty && context.mounted) {
        LoadingOverlay.show(context, message: 'Mengupload foto...');
        context.read<UserBloc>().add(
              UploadProfilePhotoEvent(photoPath: photoPath),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ToastNotification.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        LoadingOverlay.show(context, message: 'Mengupload foto...');
        context.read<UserBloc>().add(
              UploadProfilePhotoEvent(photoPath: pickedFile.path),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ToastNotification.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showPhotoPreview(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.contain,
                    // Don't cache preview images to full resolution for better quality
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutEvent());
              context.go(AppRoutes.login);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

