import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with email and password
  /// Returns a Map with 'user' and 'token'
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  
  /// Register a new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String employeeId,
  });
  
  /// Request password reset
  Future<void> forgotPassword(String email);
  
  /// Logout current user
  Future<void> logout();
  
  /// Get currently logged in user
  Future<User?> getCurrentUser();
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}

