import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

/// Improved Attendance Confirmation Page
/// Shows AFTER face verification success
class AttendanceConfirmationImproved extends StatelessWidget {
  final String photoPath;
  final String location;
  final String userId;
  final bool isClockIn;
  final bool isVerified; // NEW: Verification status
  
  const AttendanceConfirmationImproved({
    super.key,
    required this.photoPath,
    required this.location,
    required this.userId,
    required this.isClockIn,
    this.isVerified = true, // Default true since we only navigate here after verification
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(isClockIn ? 'Konfirmasi Clock In' : 'Konfirmasi Clock Out'),
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            // Show success message first
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isClockIn ? 'Clock In berhasil dicatat!' : 'Clock Out berhasil dicatat!',
                        ),
                      ),
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
              
              // Navigate to home after showing snackbar
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go(AppRoutes.home);
                }
              });
            }
          } else if (state is AttendanceError) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVerificationStatus(),
              const SizedBox(height: 16),
              _buildUserInfo(context),
              const SizedBox(height: 16),
              _buildPhotoPreview(),
              const SizedBox(height: 16),
              _buildTimeInfo(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 32),
              _buildConfirmButton(context),
              const SizedBox(height: 16),
              _buildCancelButton(context),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    if (!isVerified) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wajah Terverifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Wajah Anda cocok dengan foto profil',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: (state.user.profilePhotoUrl != null && 
                                   state.user.profilePhotoUrl!.isNotEmpty)
                      ? NetworkImage(state.user.profilePhotoUrl!)
                      : null,
                  child: (state.user.profilePhotoUrl == null || 
                         state.user.profilePhotoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.user.employeeId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        state.user.position,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(photoPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isClockIn ? Icons.login : Icons.logout,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isClockIn ? 'Waktu Masuk' : 'Waktu Keluar',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatTime(now),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                DateFormatter.formatDate(now),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        return CustomButton(
          text: isClockIn ? 'Ya, Catat Jam Masuk' : 'Ya, Catat Jam Keluar',
          onPressed: () {
            if (isClockIn) {
              context.read<AttendanceBloc>().add(
                    ClockInEvent(
                      photoPath: photoPath,
                      location: location,
                      userId: userId,
                    ),
                  );
            } else {
              context.read<AttendanceBloc>().add(
                    ClockOutEvent(
                      photoPath: photoPath,
                      location: location,
                    ),
                  );
            }
          },
          isLoading: state is AttendanceLoading,
          icon: Icons.check_circle,
          fullWidth: true,
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return CustomButton(
      text: 'Batal',
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      type: ButtonType.secondary,
      fullWidth: true,
    );
  }
}

