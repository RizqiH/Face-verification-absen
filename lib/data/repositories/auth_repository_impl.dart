import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });
  
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.login(email, password);
    
    final userModel = result['user'] as UserModel?;
    final token = result['token'] as String?;
    
    if (userModel == null) {
      throw Exception('UserModel tidak ditemukan di response');
    }
    
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak valid dari server');
    }
    
    // Save to local storage
    await localStorage.saveToken(token);
    await localStorage.saveUser(userModel);
    
    return {
      'user': userModel as User,
      'token': token,
    };
  }
  
  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String employeeId,
  }) async {
    await remoteDataSource.register(name, email, password, employeeId);
  }
  
  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }
  
  @override
  Future<void> logout() async {
    await localStorage.deleteToken();
    await localStorage.deleteUser();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    return await localStorage.getUser();
  }
  
  @override
  Future<bool> isAuthenticated() async {
    return await localStorage.isAuthenticated();
  }
}

