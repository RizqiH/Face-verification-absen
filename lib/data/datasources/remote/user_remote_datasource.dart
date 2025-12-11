import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> updateProfile(String name, String? position);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<String> uploadProfilePhoto(String photoPath);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;

  UserRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> updateProfile(String name, String? position) async {
    try {
      final response = await dioClient.dio.put(
        '/user/profile',
        data: {
          'name': name,
          if (position != null) 'position': position,
        },
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await dioClient.dio.put(
        '/user/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to change password');
    }
  }

  @override
  Future<String> uploadProfilePhoto(String photoPath) async {
    try {
      print('DEBUG: UploadProfilePhoto - Starting upload from path: $photoPath');
      
      // Check if file exists
      final file = await MultipartFile.fromFile(photoPath);
      print('DEBUG: UploadProfilePhoto - File created, size: ${file.length} bytes');
      
      final formData = FormData.fromMap({
        'photo': file,
      });
      
      print('DEBUG: UploadProfilePhoto - Making POST request to /user/upload-profile-photo');
      final response = await dioClient.dio.post(
        '/user/upload-profile-photo',
        data: formData,
      );
      
      print('DEBUG: UploadProfilePhoto - Response status: ${response.statusCode}');
      print('DEBUG: UploadProfilePhoto - Response data: ${response.data}');
      
      // Backend returns {"data": "photoURL"} where photoURL is a string
      final responseData = response.data['data'];
      String photoUrl;
      
      if (responseData is String) {
        photoUrl = responseData;
      } else if (responseData is Map) {
        photoUrl = responseData['profile_photo_url'] ?? 
                   responseData['photo_url'] ??
                   responseData['url'] ??
                   '';
      } else {
        // Fallback: try to get from root level
        photoUrl = response.data['profile_photo_url'] ?? 
                   response.data['photo_url'] ??
                   response.data['url'] ??
                   '';
      }
      
      if (photoUrl.isEmpty) {
        print('DEBUG: UploadProfilePhoto - Photo URL is empty!');
        throw Exception('URL foto tidak ditemukan di response server');
      }
      
      print('DEBUG: UploadProfilePhoto - Photo URL: $photoUrl');
      return photoUrl;
    } on DioException catch (e) {
      print('DEBUG: UploadProfilePhoto - DioException: ${e.response?.statusCode} - ${e.message}');
      print('DEBUG: UploadProfilePhoto - Error response: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Gagal mengupload foto: ${e.message}');
    } catch (e) {
      print('DEBUG: UploadProfilePhoto - Exception: $e');
      throw Exception('Gagal mengupload foto: $e');
    }
  }
}


