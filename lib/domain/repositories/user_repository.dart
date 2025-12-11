import '../../domain/entities/user.dart';

abstract class UserRepository {
  Future<User> updateProfile(String name, String? position);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<String> uploadProfilePhoto(String photoPath);
}






