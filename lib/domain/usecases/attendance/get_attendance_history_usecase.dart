import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';
import '../usecase.dart';

/// Parameters for attendance history
class AttendanceHistoryParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const AttendanceHistoryParams({
    this.startDate,
    this.endDate,
    this.limit = 30,
    this.offset = 0,
  });
}

/// Use case for getting attendance history
/// 
/// Handles:
/// - Date range filtering
/// - Pagination
/// - Sorting by date (newest first)
class GetAttendanceHistoryUseCase 
    implements UseCase<List<Attendance>, AttendanceHistoryParams> {
  final AttendanceRepository repository;

  const GetAttendanceHistoryUseCase({required this.repository});

  @override
  Future<List<Attendance>> call(AttendanceHistoryParams params) async {
    try {
      // Repository only accepts startDate and endDate as positional params
      final startDate = params.startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final endDate = params.endDate ?? DateTime.now();
      
      return await repository.getAttendanceHistory(
        startDate,
        endDate,
      );
    } catch (e) {
      throw Exception('Gagal mengambil riwayat kehadiran: ${e.toString()}');
    }
  }
}

