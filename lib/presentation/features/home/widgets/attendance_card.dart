import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/attendance.dart';
import '../../../widgets/shimmer_loading.dart';

/// Attendance card widget showing clock in/out times and buttons
class AttendanceCard extends StatelessWidget {
  final Attendance? attendance;
  final String userId;
  final bool isLoading;

  const AttendanceCard({
    super.key,
    this.attendance,
    required this.userId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: _buildClockInSection(context),
          ),
          Container(
            width: 1,
            height: 100,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Expanded(
            child: _buildClockOutSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ShimmerCard(height: 140),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ShimmerCard(height: 140),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockInSection(BuildContext context) {
    final clockInTime = attendance?.clockIn;
    final hasClockIn = clockInTime != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Absen Masuk',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasClockIn && clockInTime != null
              ? DateFormatter.formatTime(clockInTime)
              : '--:--:--',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: hasClockIn ? Colors.black87 : const Color(0xFF757575),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !hasClockIn
                ? () => _navigateToCamera(context, isClockIn: true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Clock In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!hasClockIn) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClockOutSection(BuildContext context) {
    final clockOutTime = attendance?.clockOut;
    final clockInTime = attendance?.clockIn;
    final hasClockOut = clockOutTime != null;
    final canClockOut = clockInTime != null && !hasClockOut;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Absen Keluar',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasClockOut && clockOutTime != null
              ? DateFormatter.formatTime(clockOutTime)
              : '--:--:--',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: hasClockOut ? Colors.black87 : const Color(0xFF757575),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canClockOut
                ? () => _navigateToCamera(context, isClockIn: false)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (canClockOut) ...[
                  const Icon(Icons.arrow_back, size: 18),
                  const SizedBox(width: 6),
                ],
                const Text(
                  'Clock Out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToCamera(BuildContext context, {required bool isClockIn}) {
    context.go(
      Uri(
        path: AppRoutes.cameraAttendance,
        queryParameters: {
          RouteParams.userId: userId,
          RouteParams.isClockIn: isClockIn.toString(),
        },
      ).toString(),
    );
  }
}

