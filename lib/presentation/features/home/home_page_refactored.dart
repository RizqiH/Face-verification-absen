import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/empty_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/attendance/attendance_bloc.dart';
import '../../widgets/shimmer_loading.dart';
import 'widgets/app_header.dart';
import 'widgets/user_profile_card.dart';
import 'widgets/attendance_card.dart';
import 'widgets/animated_feature_grid.dart';
import 'widgets/announcements_card.dart';

/// Refactored Home Page - Clean and modular
/// Broken down into smaller, reusable widgets
class HomePageRefactored extends StatefulWidget {
  const HomePageRefactored({super.key});

  @override
  State<HomePageRefactored> createState() => _HomePageRefactoredState();
}

class _HomePageRefactoredState extends State<HomePageRefactored> {
  @override
  void initState() {
    super.initState();
    // Load today's attendance on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery to avoid repeated calls
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: AppHeader(
              notificationCount: 5, // Demo: 5 notifications
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildUserProfile(),
                    const SizedBox(height: 16),
                    _buildAttendanceCard(),
                    const SizedBox(height: 12),
                    const AnimatedFeatureGrid(),
                    const SizedBox(height: 16),
                    const AnnouncementsCard(),
                    SizedBox(height: 80 + bottomPadding), // Dynamic padding based on device
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        // Always rebuild when state type changes
        if (previous.runtimeType != current.runtimeType) return true;
        
        // Rebuild when user data changes (especially profilePhotoUrl)
        if (previous is AuthAuthenticated && current is AuthAuthenticated) {
          return previous.user.profilePhotoUrl != current.user.profilePhotoUrl ||
                 previous.user.name != current.user.name ||
                 previous.user.position != current.user.position;
        }
        
        return false;
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return RepaintBoundary(
            child: UserProfileCard(user: state.user),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAttendanceCard() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      buildWhen: (previous, current) {
        // Only rebuild when attendance actually changes
        if (previous is AttendanceLoaded && current is AttendanceLoaded) {
          return previous.attendance != current.attendance;
        }
        if (previous is AttendanceHistoryLoaded && current is AttendanceHistoryLoaded) {
          return previous.todayAttendance != current.todayAttendance;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, attendanceState) {
        return BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            if (previous is AuthAuthenticated && current is AuthAuthenticated) {
              return previous.user.id != current.user.id;
            }
            return previous.runtimeType != current.runtimeType;
          },
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              // Determine loading state
              final isLoading = attendanceState is AttendanceLoading ||
                  attendanceState is AttendanceInitial;

              // Get attendance data
              final attendance = _getAttendanceFromState(attendanceState);

              return RepaintBoundary(
                child: AttendanceCard(
                  attendance: attendance,
                  userId: authState.user.id,
                  isLoading: isLoading,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  /// Extract attendance from different state types
  dynamic _getAttendanceFromState(AttendanceState state) {
    if (state is AttendanceLoaded) {
      return state.attendance;
    } else if (state is AttendanceHistoryLoaded) {
      return state.todayAttendance;
    } else if (state is AttendanceHistoryLoading) {
      return state.todayAttendance;
    }
    return null;
  }

  Future<void> _handleRefresh() async {
    context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

