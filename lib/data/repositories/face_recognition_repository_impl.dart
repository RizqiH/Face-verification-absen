import '../../domain/repositories/face_recognition_repository.dart';
import '../datasources/remote/face_recognition_remote_datasource.dart';

class FaceRecognitionRepositoryImpl implements FaceRecognitionRepository {
  final FaceRecognitionRemoteDataSource remoteDataSource;
  
  FaceRecognitionRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<String> uploadProfilePhoto(String photoPath, String userId) {
    return remoteDataSource.uploadProfilePhoto(photoPath, userId);
  }
  
  @override
  Future<bool> verifyFace(String photoPath, String userId) {
    return remoteDataSource.verifyFace(photoPath, userId);
  }
}

