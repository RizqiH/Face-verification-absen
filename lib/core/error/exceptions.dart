/// Base exception class for all exceptions in the app
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

// ============================================
// Network Exceptions
// ============================================

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ConnectionException extends AppException {
  const ConnectionException({
    String message = 'No internet connection',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Connection timeout',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Auth Exceptions
// ============================================

class AuthenticationException extends AppException {
  const AuthenticationException({
    String message = 'Authentication failed',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Data Exceptions
// ============================================

class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error',
    super.code,
    super.originalError,
  }) : super(message: message);
}

class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Not found',
    super.code,
    super.originalError,
  }) : super(message: message);
}

// ============================================
// Validation Exceptions
// ============================================

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

