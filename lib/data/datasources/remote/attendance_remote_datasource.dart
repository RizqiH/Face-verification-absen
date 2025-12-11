import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> clockIn(String photoPath, String location);
  Future<AttendanceModel> clockOut(String photoPath, String location);
  Future<AttendanceModel?> getTodayAttendance();
  Future<List<AttendanceModel>> getAttendanceHistory(DateTime startDate, DateTime endDate);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient dioClient;
  
  AttendanceRemoteDataSourceImpl({required this.dioClient});
  
  @override
  Future<AttendanceModel> clockIn(String photoPath, String location) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photoPath),
        'location': location,
      });
      
      final response = await dioClient.dio.post(
        '/attendance/clock-in',
        data: formData,
      );
      
      // Validate response data structure
      if (response.data == null) {
        throw Exception('Invalid response: response data is null');
      }
      
      if (response.data['data'] == null) {
        throw Exception('Invalid response: attendance data is null');
      }
      
      // Ensure data is a Map, not null
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response: attendance data is not a valid object');
      }
      
      return AttendanceModel.fromJson(data);
    } on DioException catch (e) {
      // Backend returns {"error": "..."} on 400
      final errorMsg = e.response?.data['error'] ?? 
                      e.response?.data['message'] ?? 
                      'Clock in failed';
      throw Exception(errorMsg);
    }
  }
  
  @override
  Future<AttendanceModel> clockOut(String photoPath, String location) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photoPath),
        'location': location,
      });
      
      final response = await dioClient.dio.post(
        '/attendance/clock-out',
        data: formData,
      );
      
      // Validate response data structure
      if (response.data == null) {
        throw Exception('Invalid response: response data is null');
      }
      
      if (response.data['data'] == null) {
        throw Exception('Invalid response: attendance data is null');
      }
      
      // Ensure data is a Map, not null
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response: attendance data is not a valid object');
      }
      
      return AttendanceModel.fromJson(data);
    } on DioException catch (e) {
      // Backend returns {"error": "..."} on 400
      final errorMsg = e.response?.data['error'] ?? 
                      e.response?.data['message'] ?? 
                      'Clock out failed';
      throw Exception(errorMsg);
    }
  }
  
  @override
  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      print('DEBUG: Making GET request to /attendance/today');
      final response = await dioClient.dio.get('/attendance/today');
      print('DEBUG: Response status: ${response.statusCode}');
      if (response.data['data'] == null) {
        print('DEBUG: Response data is null');
        return null;
      }
      print('DEBUG: Attendance data found');
      return AttendanceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('DEBUG: DioException: ${e.response?.statusCode} - ${e.message}');
      // If 401, return null instead of throwing to prevent infinite loading
      if (e.response?.statusCode == 401) {
        print('DEBUG: 401 Unauthorized - returning null');
        return null;
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to get attendance');
    }
  }
  
  @override
  Future<List<AttendanceModel>> getAttendanceHistory(DateTime startDate, DateTime endDate) async {
    try {
      final response = await dioClient.dio.get(
        '/attendance/history',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => AttendanceModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get history');
    }
  }
}

