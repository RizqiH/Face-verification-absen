import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> updateProfile(String name, String? position) {
    return remoteDataSource.updateProfile(name, position);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) {
    return remoteDataSource.changePassword(oldPassword, newPassword);
  }

  @override
  Future<String> uploadProfilePhoto(String photoPath) {
    return remoteDataSource.uploadProfilePhoto(photoPath);
  }
}






