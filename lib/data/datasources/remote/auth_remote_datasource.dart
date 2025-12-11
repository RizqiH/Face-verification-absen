import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> register(String name, String email, String password, String employeeId);
  Future<void> forgotPassword(String email);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  
  AuthRemoteDataSourceImpl({required this.dioClient});
  
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('DEBUG: AuthRemoteDataSource.login - Making POST request to /auth/login');
      final response = await dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print('DEBUG: AuthRemoteDataSource.login - Response status: ${response.statusCode}');
      print('DEBUG: AuthRemoteDataSource.login - Response data: ${response.data}');
      
      final responseData = response.data;
      if (responseData == null) {
        throw Exception('Response data is null');
      }
      
      final token = responseData['token'];
      final userData = responseData['data'];
      
      print('DEBUG: AuthRemoteDataSource.login - Token: ${token != null ? "exists" : "null"}');
      print('DEBUG: AuthRemoteDataSource.login - User data: ${userData != null ? "exists" : "null"}');
      
      if (token == null) {
        throw Exception('Token tidak ditemukan di response server');
      }
      
      if (userData == null) {
        throw Exception('Data user tidak ditemukan di response server');
      }
      
      final tokenString = token.toString();
      if (tokenString.isEmpty) {
        throw Exception('Token kosong');
      }
      
      print('DEBUG: AuthRemoteDataSource.login - Parsing UserModel');
      final userModel = UserModel.fromJson(userData);
      print('DEBUG: AuthRemoteDataSource.login - UserModel parsed successfully');
      
      return {
        'user': userModel,
        'token': tokenString,
      };
    } on DioException catch (e) {
      print('DEBUG: AuthRemoteDataSource.login - DioException: ${e.response?.statusCode} - ${e.message}');
      print('DEBUG: AuthRemoteDataSource.login - Error response: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    } catch (e) {
      print('DEBUG: AuthRemoteDataSource.login - Exception: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> register(String name, String email, String password, String employeeId) async {
    try {
      await dioClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'employee_id': employeeId,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Registration failed');
    }
  }
  
  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send reset email');
    }
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.dio.get('/auth/me');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      // If 401, token is invalid or expired, clear it
      if (e.response?.statusCode == 401) {
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to get user');
    }
  }
}

