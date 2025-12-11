import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/attendance.dart';

/// Widget for displaying a single attendance history item
class AttendanceHistoryItem extends StatelessWidget {
  final Attendance attendance;

  const AttendanceHistoryItem({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                attendance.clockIn != null
                    ? DateFormatter.formatDate(attendance.clockIn!)
                    : DateFormatter.formatDate(attendance.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Clock In',
                  attendance.clockIn,
                  Icons.login,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildTimeInfo(
                  'Clock Out',
                  attendance.clockOut,
                  Icons.logout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final hasClockOut = attendance.clockOut != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasClockOut ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hasClockOut ? 'Lengkap' : 'Belum Keluar',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: hasClockOut ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, DateTime? time, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time != null ? DateFormatter.formatTime(time) : '--:--:--',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: time != null ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

