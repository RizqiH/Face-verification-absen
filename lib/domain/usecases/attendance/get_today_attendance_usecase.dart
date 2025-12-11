import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';
import '../usecase.dart';

/// Use case for getting today's attendance
/// 
/// Returns the attendance record for the current day
/// Returns null if no attendance record exists for today
class GetTodayAttendanceUseCase implements UseCase<Attendance?, NoParams> {
  final AttendanceRepository repository;

  const GetTodayAttendanceUseCase({required this.repository});

  @override
  Future<Attendance?> call(NoParams params) async {
    try {
      return await repository.getTodayAttendance();
    } catch (e) {
      // Log error but don't throw - return null if no attendance today
      print('Error getting today attendance: $e');
      return null;
    }
  }
}

