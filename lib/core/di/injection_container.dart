import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/attendance_remote_datasource.dart';
import '../../data/datasources/remote/face_recognition_remote_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/datasources/remote/training_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/face_recognition_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/training_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/face_recognition_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/training_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/attendance/clock_in_usecase.dart';
import '../../domain/usecases/attendance/clock_out_usecase.dart';
import '../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../domain/usecases/attendance/get_today_attendance_usecase.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/attendance/attendance_bloc.dart';
import '../../presentation/bloc/task/task_bloc.dart';
import '../../presentation/bloc/training/training_bloc.dart';
import '../../presentation/bloc/user/user_bloc.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance; // Service Locator

/// Initialize all dependencies
/// Call this once in main() before runApp()
Future<void> initializeDependencies() async {
  // ============================================================
  // External Dependencies
  // ============================================================
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // ============================================================
  // Core
  // ============================================================
  
  // Dio Client (Singleton for main API)
  sl.registerLazySingleton<DioClient>(() => DioClient());
  
  // Separate Dio for Face Recognition Service
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(
      baseUrl: 'http://192.168.1.142:5001',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120), // Longer for face recognition processing
      sendTimeout: const Duration(seconds: 90), // For sending large files
    )),
    instanceName: 'faceRecognitionDio',
  );
  
  // Local Storage
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(sharedPreferences: sl()),
  );
  
  // ============================================================
  // Data Sources
  // ============================================================
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<FaceRecognitionRemoteDataSource>(
    () => FaceRecognitionRemoteDataSourceImpl(
      dio: sl(instanceName: 'faceRecognitionDio'),
    ),
  );
  
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<TrainingRemoteDataSource>(
    () => TrainingRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dioClient: sl()),
  );
  
  // ============================================================
  // Repositories
  // ============================================================
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localStorage: sl(),
    ),
  );
  
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<FaceRecognitionRepository>(
    () => FaceRecognitionRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<TrainingRepository>(
    () => TrainingRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  
  // ============================================================
  // Use Cases
  // ============================================================
  
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  
  // Attendance Use Cases
  sl.registerLazySingleton(() => ClockInUseCase(
        attendanceRepository: sl(),
        faceRecognitionRepository: sl(),
      ));
  sl.registerLazySingleton(() => ClockOutUseCase(
        attendanceRepository: sl(),
        faceRecognitionRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetTodayAttendanceUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(repository: sl()));
  
  // ============================================================
  // BLoCs (Factories - new instance each time)
  // ============================================================
  
  sl.registerFactory(
    () => AuthBloc(
      authRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AttendanceBloc(
      clockInUseCase: sl(),
      attendanceRepository: sl(),
    ),
  );
  
  sl.registerFactory(
    () => TaskBloc(taskRepository: sl()),
  );
  
  sl.registerFactory(
    () => TrainingBloc(trainingRepository: sl()),
  );
  
  sl.registerFactory(
    () => UserBloc(
      userRepository: sl(),
      authBloc: sl(),
    ),
  );
}

/// Clear all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}

