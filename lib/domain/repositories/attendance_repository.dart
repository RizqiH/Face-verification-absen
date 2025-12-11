import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<Attendance> clockIn(String photoPath, String location);
  Future<Attendance> clockOut(String photoPath, String location);
  Future<Attendance?> getTodayAttendance();
  Future<List<Attendance>> getAttendanceHistory(DateTime startDate, DateTime endDate);
}

