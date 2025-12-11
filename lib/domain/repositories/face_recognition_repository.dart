abstract class FaceRecognitionRepository {
  Future<String> uploadProfilePhoto(String photoPath, String userId);
  Future<bool> verifyFace(String photoPath, String userId);
}

