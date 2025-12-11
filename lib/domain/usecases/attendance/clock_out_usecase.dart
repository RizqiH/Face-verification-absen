import '../../repositories/attendance_repository.dart';
import '../../repositories/face_recognition_repository.dart';
import '../usecase.dart';

/// Parameters for clock out use case
class ClockOutParams {
  final String photoPath;
  final String location;

  const ClockOutParams({
    required this.photoPath,
    required this.location,
  });
}

/// Use case for clocking out
/// 
/// Handles:
/// - Face verification
/// - Location validation
/// - Clock out time recording
/// - Error handling for verification failures
class ClockOutUseCase implements UseCase<void, ClockOutParams> {
  final AttendanceRepository attendanceRepository;
  final FaceRecognitionRepository faceRecognitionRepository;

  const ClockOutUseCase({
    required this.attendanceRepository,
    required this.faceRecognitionRepository,
  });

  @override
  Future<void> call(ClockOutParams params) async {
    // Validate photo path
    if (params.photoPath.isEmpty) {
      throw Exception('Foto tidak valid');
    }

    // Validate location
    if (params.location.isEmpty) {
      throw Exception('Lokasi tidak tersedia');
    }

    // Verify face first
    try {
      final isVerified = await faceRecognitionRepository.verifyFace(
        params.photoPath,
        '', // userId - will be retrieved from token by repository
      );

      if (!isVerified) {
        throw Exception(
          'Verifikasi wajah gagal. Pastikan wajah Anda terlihat jelas.',
        );
      }
    } catch (e) {
      throw Exception('Gagal memverifikasi wajah: ${e.toString()}');
    }

    // If verified, proceed with clock out
    try {
      await attendanceRepository.clockOut(
        params.photoPath,
        params.location,
      );
    } catch (e) {
      throw Exception('Gagal mencatat jam keluar: ${e.toString()}');
    }
  }
}

