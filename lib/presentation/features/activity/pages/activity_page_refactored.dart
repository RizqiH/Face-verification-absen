import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../domain/entities/attendance.dart';
import '../../../bloc/attendance/attendance_bloc.dart';
import '../../../widgets/shimmer_loading.dart';
import '../widgets/attendance_history_item.dart';

/// Refactored Activity Page showing attendance history
class ActivityPageRefactored extends StatefulWidget {
  const ActivityPageRefactored({super.key});

  @override
  State<ActivityPageRefactored> createState() => _ActivityPageRefactoredState();
}

class _ActivityPageRefactoredState extends State<ActivityPageRefactored> {
  @override
  void initState() {
    super.initState();
    // Load attendance history - using GetTodayAttendanceEvent since GetAttendanceHistoryEvent doesn't exist yet
    context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Aktivitas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // Prevent back button from exiting app, navigate within app instead
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          buildWhen: (previous, current) {
            // Only rebuild when state type changes or data actually changes
            if (previous is AttendanceHistoryLoaded && current is AttendanceHistoryLoaded) {
              return previous.history != current.history ||
                     previous.todayAttendance != current.todayAttendance;
            }
            return previous.runtimeType != current.runtimeType;
          },
          builder: (context, state) {
            if (state is AttendanceHistoryLoading && state.todayAttendance == null) {
              return const ShimmerList(itemCount: 5, itemHeight: 120);
            }

            if (state is AttendanceError) {
              return _buildError(state.message);
            }

            final todayAttendance = _getTodayAttendance(state);
            final historyList = _getHistoryList(state);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todayAttendance != null) ...[
                    RepaintBoundary(
                      child: _buildTodayCard(todayAttendance),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Riwayat Kehadiran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    child: _buildHistoryList(historyList),
                  ),
                ],
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(Attendance attendance) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kehadiran Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeItem(
                  'Masuk',
                  attendance.clockIn != null
                      ? DateFormatter.formatTime(attendance.clockIn!)
                      : '--:--:--',
                  attendance.clockIn != null,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildTimeItem(
                  'Keluar',
                  attendance.clockOut != null
                      ? DateFormatter.formatTime(attendance.clockOut!)
                      : '--:--:--',
                  attendance.clockOut != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String time, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<Attendance> history) {
    if (history.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'Belum Ada Riwayat',
        subtitle: 'Riwayat kehadiran Anda akan muncul di sini',
        actionText: 'Muat Ulang',
        onActionPressed: () {
          context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
        },
      );
    }

    return Column(
      children: history.map((attendance) {
        return RepaintBoundary(
          key: ValueKey(attendance.id), // Use stable keys
          child: AttendanceHistoryItem(attendance: attendance),
        );
      }).toList(),
    );
  }

  Attendance? _getTodayAttendance(AttendanceState state) {
    if (state is AttendanceLoaded) {
      return state.attendance;
    } else if (state is AttendanceHistoryLoaded) {
      return state.todayAttendance;
    } else if (state is AttendanceHistoryLoading) {
      return state.todayAttendance;
    }
    return null;
  }

  List<Attendance> _getHistoryList(AttendanceState state) {
    if (state is AttendanceHistoryLoaded) {
      return state.history;
    }
    return [];
  }

  Future<void> _handleRefresh() async {
    context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

