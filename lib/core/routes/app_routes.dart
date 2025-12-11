import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/features/auth/pages/login_page_refactored.dart';
import '../../presentation/features/auth/pages/register_page_refactored.dart';
import '../../presentation/features/auth/pages/forgot_password_page_refactored.dart';
import '../../presentation/features/home/home_page_with_nav.dart';
import '../../presentation/features/activity/pages/activity_page_refactored.dart';
import '../../presentation/features/tasks/pages/tasks_page_refactored.dart';
import '../../presentation/features/training/pages/training_page_refactored.dart';
import '../../presentation/features/profile/pages/profile_page_refactored.dart';
import '../../presentation/features/profile/pages/edit_profile_page_refactored.dart';
import '../../presentation/features/profile/pages/change_password_page_refactored.dart';
import '../../presentation/features/profile/pages/settings_page_refactored.dart';
import '../../presentation/features/profile/pages/camera_profile_page.dart';
import '../../presentation/features/attendance/pages/camera_attendance_improved.dart';
import '../../presentation/features/attendance/pages/attendance_confirmation_improved.dart';
import '../../presentation/features/attendance_management/pages/attendance_management_page.dart';
import '../../presentation/features/talent/pages/talent_page.dart';
import '../../presentation/features/report/pages/report_page.dart';
import '../../presentation/features/spaces/pages/spaces_page.dart';
import '../../presentation/features/overtime/pages/overtime_page.dart';
import '../../presentation/features/reimbursement/pages/reimbursement_page.dart';
import '../../presentation/features/facilities/pages/facilities_page.dart';
import '../../presentation/features/loan/pages/loan_page.dart';
import '../../presentation/features/advance/pages/advance_page.dart';
import '../../presentation/features/splash/splash_page.dart';

/// Route names as constants for type safety
class AppRoutes {
  // Splash route
  static const String splash = '/splash';
  
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main app routes
  static const String home = '/';
  static const String activity = '/activity';
  static const String tasks = '/tasks';
  static const String training = '/training';
  static const String profile = '/profile';
  
  // Profile sub-routes
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/settings';
  static const String cameraProfile = '/profile/camera';
  
  // Attendance routes
  static const String cameraAttendance = '/attendance/camera';
  static const String attendanceConfirmation = '/attendance/confirmation';
  static const String attendanceManagement = '/attendance-management';
  
  // Feature routes
  static const String talent = '/talent';
  static const String report = '/report';
  static const String spaces = '/spaces';
  static const String overtime = '/overtime';
  static const String reimbursement = '/reimbursement';
  static const String facilities = '/facilities';
  static const String loan = '/loan';
  static const String advance = '/advance';
}

/// Route parameters
class RouteParams {
  static const String userId = 'userId';
  static const String isClockIn = 'isClockIn';
  static const String photoPath = 'photoPath';
  static const String location = 'location';
}

/// Create GoRouter configuration
GoRouter createAppRouter(BuildContext context) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash, // Start from splash while checking auth
    
    // Redirect logic based on auth state
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading = authState is AuthInitial || authState is AuthLoading;
      
      // Show splash while checking auth
      if (isLoading && !isSplashRoute) {
        return AppRoutes.splash;
      }
      
      // Auth check complete - redirect from splash
      if (isSplashRoute && !isLoading) {
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }
      
      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        return AppRoutes.login;
      }
      
      // Redirect authenticated users away from auth pages
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      
      return null; // No redirect needed
    },
    
    // Route refresh listener - rebuild routes when auth state changes
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthBloc>().stream,
    ),
    
    routes: [
      // ============================================
      // SPLASH ROUTE
      // ============================================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      
      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordPageRefactored(),
        ),
      ),
      
      // ============================================
      // MAIN APP ROUTES (Protected)
      // ============================================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomePageWithNav(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.activity,
        name: 'activity',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ActivityPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.tasks,
        name: 'tasks',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TasksPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.training,
        name: 'training',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TrainingPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfilePageRefactored(),
        ),
      ),
      
      // ============================================
      // PROFILE SUB-ROUTES
      // ============================================
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EditProfilePageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'change-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ChangePasswordPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SettingsPageRefactored(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.cameraProfile,
        name: 'camera-profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CameraProfilePage(),
        ),
      ),
      
      // ============================================
      // FEATURE ROUTES
      // ============================================
      GoRoute(
        path: AppRoutes.attendanceManagement,
        name: 'attendance-management',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AttendanceManagementPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.talent,
        name: 'talent',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TalentPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.report,
        name: 'report',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReportPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.spaces,
        name: 'spaces',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SpacesPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.overtime,
        name: 'overtime',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OvertimePage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.reimbursement,
        name: 'reimbursement',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReimbursementPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.facilities,
        name: 'facilities',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const FacilitiesPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.loan,
        name: 'loan',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoanPage(),
        ),
      ),
      
      GoRoute(
        path: AppRoutes.advance,
        name: 'advance',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AdvancePage(),
        ),
      ),
      
      // ============================================
      // ATTENDANCE ROUTES
      // ============================================
      GoRoute(
        path: AppRoutes.cameraAttendance,
        name: 'camera-attendance',
        pageBuilder: (context, state) {
          final userId = state.uri.queryParameters[RouteParams.userId] ?? '';
          final isClockIn = state.uri.queryParameters[RouteParams.isClockIn] == 'true';
          
          return MaterialPage(
            key: state.pageKey,
            child: CameraAttendanceImproved(
              userId: userId,
              isClockIn: isClockIn,
            ),
          );
        },
      ),
      
      GoRoute(
        path: AppRoutes.attendanceConfirmation,
        name: 'attendance-confirmation',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          
          return MaterialPage(
            key: state.pageKey,
            child: AttendanceConfirmationImproved(
              photoPath: extra?[RouteParams.photoPath] ?? '',
              location: extra?[RouteParams.location] ?? '',
              userId: extra?[RouteParams.userId] ?? '',
              isClockIn: extra?[RouteParams.isClockIn] ?? true,
              isVerified: extra?['isVerified'] ?? true,
            ),
          );
        },
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
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
              'Error: ${state.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Extension methods for easier navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to a route by name
  void navigateToNamed(String name, {Map<String, String>? params, Object? extra}) {
    go(name, extra: extra);
  }
  
  /// Navigate to camera attendance page
  void navigateToCameraAttendance({
    required String userId,
    required bool isClockIn,
  }) {
    go(
      Uri(
        path: AppRoutes.cameraAttendance,
        queryParameters: {
          RouteParams.userId: userId,
          RouteParams.isClockIn: isClockIn.toString(),
        },
      ).toString(),
    );
  }
  
  /// Navigate to attendance confirmation
  void navigateToAttendanceConfirmation({
    required String photoPath,
    required String location,
    required String userId,
    required bool isClockIn,
  }) {
    go(
      AppRoutes.attendanceConfirmation,
      extra: {
        RouteParams.photoPath: photoPath,
        RouteParams.location: location,
        RouteParams.userId: userId,
        RouteParams.isClockIn: isClockIn,
      },
    );
  }
}

