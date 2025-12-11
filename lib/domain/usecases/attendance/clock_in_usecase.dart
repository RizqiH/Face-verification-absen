import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';
import '../../repositories/face_recognition_repository.dart';

class ClockInUseCase {
  final AttendanceRepository attendanceRepository;
  final FaceRecognitionRepository faceRecognitionRepository;
  
  ClockInUseCase({
    required this.attendanceRepository,
    required this.faceRecognitionRepository,
  });
  
  Future<Attendance> execute(String photoPath, String location, String userId) async {
    // Verify face first
    final isVerified = await faceRecognitionRepository.verifyFace(photoPath, userId);
    if (!isVerified) {
      throw Exception('Face verification failed');
    }
    
    // Clock in after verification
    return await attendanceRepository.clockIn(photoPath, location);
  }
}

