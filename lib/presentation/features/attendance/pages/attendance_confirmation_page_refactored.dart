import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';

class AttendanceConfirmationPageRefactored extends StatelessWidget {
  final String photoPath;
  final String location;
  final String userId;
  final bool isClockIn;
  
  const AttendanceConfirmationPageRefactored({
    super.key,
    required this.photoPath,
    required this.location,
    required this.userId,
    required this.isClockIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Catat Kehadiran'),
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            context.go(AppRoutes.home);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Absensi berhasil dicatat'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(context),
              const SizedBox(height: 16),
              _buildPhotoPreview(),
              const SizedBox(height: 16),
              _buildTimeInfo(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 24),
              _buildConfirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.user.name,
                style: const TextStyle(
                  fontSize: 20,
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
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Masuk',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatTime(now),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Lokasi tidak tepat? ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Implement location update
                },
                child: const Text(
                  'Perbaharui lokasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final isLoading = state is AttendanceLoading;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
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
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.arrow_forward),
            label: Text(isClockIn ? 'Catat Jam Masuk' : 'Catat Jam Keluar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        );
      },
    );
  }
}

