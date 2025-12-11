import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
/// Using sealed class pattern (via factory constructor) to represent all possible failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];
}

// ============================================
// Network Failures
// ============================================

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({
    String message = 'Tidak ada koneksi internet',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Koneksi timeout, silakan coba lagi',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Auth Failures
// ============================================

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Authentication failed',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Sesi Anda telah berakhir, silakan login kembali',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    String message = 'Email atau password salah',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Validation Failures
// ============================================

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

// ============================================
// Data Failures
// ============================================

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Gagal menyimpan data lokal',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Data tidak ditemukan',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Face Recognition Failures
// ============================================

class FaceVerificationFailure extends Failure {
  const FaceVerificationFailure({
    String message = 'Verifikasi wajah gagal',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class FaceNotDetectedFailure extends Failure {
  const FaceNotDetectedFailure({
    String message = 'Wajah tidak terdeteksi, pastikan pencahayaan cukup',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Permission Failures
// ============================================

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

class CameraPermissionDeniedFailure extends PermissionDeniedFailure {
  const CameraPermissionDeniedFailure({
    String message = 'Izin kamera diperlukan untuk mengambil foto',
  }) : super(message: message);
}

class LocationPermissionDeniedFailure extends PermissionDeniedFailure {
  const LocationPermissionDeniedFailure({
    String message = 'Izin lokasi diperlukan untuk mencatat kehadiran',
  }) : super(message: message);
}

// ============================================
// Unknown Failure
// ============================================

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Terjadi kesalahan, silakan coba lagi',
    super.code,
    super.originalError,
  }) : super(message: message);
}

