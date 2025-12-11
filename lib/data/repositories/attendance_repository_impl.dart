import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/remote/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  
  AttendanceRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Attendance> clockIn(String photoPath, String location) {
    return remoteDataSource.clockIn(photoPath, location);
  }
  
  @override
  Future<Attendance> clockOut(String photoPath, String location) {
    return remoteDataSource.clockOut(photoPath, location);
  }
  
  @override
  Future<Attendance?> getTodayAttendance() {
    return remoteDataSource.getTodayAttendance();
  }
  
  @override
  Future<List<Attendance>> getAttendanceHistory(DateTime startDate, DateTime endDate) {
    return remoteDataSource.getAttendanceHistory(startDate, endDate);
  }
}

