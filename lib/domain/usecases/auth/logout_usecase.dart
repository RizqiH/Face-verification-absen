import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Use case for user logout
/// 
/// Handles:
/// - Token invalidation
/// - Local data cleanup
/// - Session termination
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const LogoutUseCase({required this.repository});

  @override
  Future<void> call(NoParams params) async {
    await repository.logout();
  }
}

