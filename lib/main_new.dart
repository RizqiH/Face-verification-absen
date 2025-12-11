import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection_container.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/attendance/attendance_bloc.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/training/training_bloc.dart';
import 'presentation/bloc/user/user_bloc.dart';

/// Main entry point for the application
/// This version uses:
/// - Dependency Injection with GetIt
/// - Modern routing with go_router
/// - Clean architecture patterns
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize dependency injection container
  await initializeDependencies();

  // Configure logger (disable in production)
  AppLogger.setEnabled(true);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - handles authentication
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(CheckAuthEvent()),
        ),

        // Attendance BLoC - handles attendance operations
        BlocProvider(
          create: (context) => sl<AttendanceBloc>(),
        ),

        // Task BLoC - handles task operations
        BlocProvider(
          create: (context) => sl<TaskBloc>(),
        ),

        // Training BLoC - handles training operations
        BlocProvider(
          create: (context) => sl<TrainingBloc>(),
        ),

        // User BLoC - handles user profile operations
        BlocProvider(
          create: (context) => sl<UserBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Create router with context that has BLoC providers
          final router = createAppRouter(context);

          return MaterialApp.router(
            title: 'Face Verification Attendance',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

