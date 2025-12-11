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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(CheckAuthEvent());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app is resumed from background, re-check auth status
    if (state == AppLifecycleState.resumed) {
      AppLogger.info('App resumed - checking auth status');
      _authBloc.add(CheckAuthEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - handles authentication
        BlocProvider.value(
          value: _authBloc,
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
        // IMPORTANT: Pass the same AuthBloc instance!
        BlocProvider(
          create: (context) => UserBloc(
            userRepository: sl(),
            authBloc: _authBloc, // Use same instance as above
          ),
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
