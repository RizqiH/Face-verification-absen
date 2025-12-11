import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Login use case parameters
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// Login use case response
class LoginResult {
  final User user;
  final String token;

  const LoginResult({
    required this.user,
    required this.token,
  });
}

/// Use case for user login
/// 
/// Handles:
/// - Credential validation
/// - API call to backend
/// - Token storage
/// - User data caching
class LoginUseCase implements UseCase<LoginResult, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase({required this.repository});

  @override
  Future<LoginResult> call(LoginParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      throw Exception('Format email tidak valid');
    }

    // Validate password length
    if (params.password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (params.password.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    // Call repository to perform login
    final result = await repository.login(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );

    return LoginResult(
      user: result['user'] as User,
      token: result['token'] as String,
    );
  }

  /// Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

