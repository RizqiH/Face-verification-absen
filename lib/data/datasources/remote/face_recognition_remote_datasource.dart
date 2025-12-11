import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

abstract class FaceRecognitionRemoteDataSource {
  Future<String> uploadProfilePhoto(String photoPath, String userId);
  Future<bool> verifyFace(String photoPath, String userId);
}

class FaceRecognitionRemoteDataSourceImpl implements FaceRecognitionRemoteDataSource {
  final Dio dio;
  
  FaceRecognitionRemoteDataSourceImpl({required this.dio});
  
  @override
  Future<String> uploadProfilePhoto(String photoPath, String userId) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photoPath),
        'user_id': userId, // Include user_id for face recognition service
      });
      
      print('DEBUG: Uploading profile photo to face recognition service for user: $userId');
      final response = await dio.post(
        '${AppConstants.faceRecognitionUrl}/upload-profile',
        data: formData,
      );
      print('DEBUG: Face recognition upload response: ${response.data}');
      
      return response.data['embedding_id'] as String;
    } on DioException catch (e) {
      print('DEBUG: Face recognition upload failed: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? e.response?.data['message'] ?? 'Upload failed');
    }
  }
  
  @override
  Future<bool> verifyFace(String photoPath, String userId) async {
    try {
      print('DEBUG: VerifyFace - Starting verification for user: $userId');
      print('DEBUG: VerifyFace - Photo path: $photoPath');
      
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photoPath),
        'user_id': userId,
      });
      
      print('DEBUG: VerifyFace - Making POST request to /verify');
      final response = await dio.post(
        '${AppConstants.faceRecognitionUrl}/verify',
        data: formData,
      );
      
      print('DEBUG: VerifyFace - Response status: ${response.statusCode}');
      print('DEBUG: VerifyFace - Response data: ${response.data}');
      
      final verified = response.data['verified'] as bool? ?? false;
      final similarity = response.data['similarity'] as double?;
      
      print('DEBUG: VerifyFace - Verified: $verified, Similarity: $similarity');
      
      return verified;
    } on DioException catch (e) {
      print('DEBUG: VerifyFace - DioException: ${e.response?.statusCode}');
      print('DEBUG: VerifyFace - Error data: ${e.response?.data}');
      
      final errorMessage = e.response?.data is Map 
          ? (e.response?.data['error'] ?? e.response?.data['message'] ?? 'Verification failed')
          : 'Verification failed: ${e.message}';
      
      throw Exception(errorMessage);
    } catch (e) {
      print('DEBUG: VerifyFace - Exception: $e');
      throw Exception('Verification failed: $e');
    }
  }
}

