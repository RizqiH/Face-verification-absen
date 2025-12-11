import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Register use case parameters
class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String employeeId;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.employeeId,
  });
}

/// Use case for user registration
/// 
/// Handles:
/// - Input validation
/// - Email format checking
/// - Password strength validation
/// - Employee ID validation
/// - API call to backend
class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  const RegisterUseCase({required this.repository});

  @override
  Future<void> call(RegisterParams params) async {
    // Validate name
    if (params.name.trim().isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    if (params.name.trim().length < 3) {
      throw Exception('Nama minimal 3 karakter');
    }

    // Validate email
    if (!_isValidEmail(params.email)) {
      throw Exception('Format email tidak valid');
    }

    // Validate password
    if (params.password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (params.password.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    // Validate employee ID
    if (params.employeeId.trim().isEmpty) {
      throw Exception('Employee ID tidak boleh kosong');
    }

    // Call repository to perform registration
    await repository.register(
      name: params.name.trim(),
      email: params.email.trim().toLowerCase(),
      password: params.password,
      employeeId: params.employeeId.trim(),
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

