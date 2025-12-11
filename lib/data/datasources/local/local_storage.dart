import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';

/// Abstract interface for local storage operations
/// This allows us to easily swap implementations or mock for testing
abstract class LocalStorage {
  /// Save authentication token
  Future<bool> saveToken(String token);
  
  /// Get authentication token
  Future<String?> getToken();
  
  /// Delete authentication token
  Future<bool> deleteToken();
  
  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();
  
  /// Save user data
  Future<bool> saveUser(User user);
  
  /// Get user data
  Future<User?> getUser();
  
  /// Delete user data
  Future<bool> deleteUser();
  
  /// Clear all stored data
  Future<bool> clearAll();
  
  /// Save any generic data
  Future<bool> saveString(String key, String value);
  
  /// Get generic string data
  Future<String?> getString(String key);
  
  /// Save boolean
  Future<bool> saveBool(String key, bool value);
  
  /// Get boolean
  Future<bool?> getBool(String key);
  
  /// Save integer
  Future<bool> saveInt(String key, int value);
  
  /// Get integer
  Future<int?> getInt(String key);
  
  /// Save double
  Future<bool> saveDouble(String key, double value);
  
  /// Get double
  Future<double?> getDouble(String key);
  
  /// Remove a specific key
  Future<bool> remove(String key);
  
  /// Check if a key exists
  Future<bool> containsKey(String key);
}

/// Implementation using SharedPreferences
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _sharedPreferences;
  
  LocalStorageImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;
  
  @override
  Future<bool> saveToken(String token) async {
    try {
      return await _sharedPreferences.setString(AppConstants.tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }
  
  @override
  Future<String?> getToken() async {
    try {
      return _sharedPreferences.getString(AppConstants.tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
  
  @override
  Future<bool> deleteToken() async {
    try {
      return await _sharedPreferences.remove(AppConstants.tokenKey);
    } catch (e) {
      print('Error deleting token: $e');
      return false;
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  @override
  Future<bool> saveUser(User user) async {
    try {
      final userJson = jsonEncode({
        'id': user.id,
        'employee_id': user.employeeId,
        'name': user.name,
        'email': user.email,
        'position': user.position,
        'department': user.department,
        'profile_photo_url': user.profilePhotoUrl,
      });
      return await _sharedPreferences.setString(AppConstants.userKey, userJson);
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }
  
  @override
  Future<User?> getUser() async {
    try {
      final userJson = _sharedPreferences.getString(AppConstants.userKey);
      if (userJson == null) return null;
      
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User(
        id: userMap['id'],
        employeeId: userMap['employee_id'],
        name: userMap['name'],
        email: userMap['email'],
        position: userMap['position'] ?? '',
        department: userMap['department'] ?? '',
        profilePhotoUrl: userMap['profile_photo_url'],
      );
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  @override
  Future<bool> deleteUser() async {
    try {
      return await _sharedPreferences.remove(AppConstants.userKey);
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
  
  @override
  Future<bool> clearAll() async {
    try {
      return await _sharedPreferences.clear();
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
  
  @override
  Future<bool> saveString(String key, String value) async {
    try {
      return await _sharedPreferences.setString(key, value);
    } catch (e) {
      print('Error saving string for key $key: $e');
      return false;
    }
  }
  
  @override
  Future<String?> getString(String key) async {
    try {
      return _sharedPreferences.getString(key);
    } catch (e) {
      print('Error getting string for key $key: $e');
      return null;
    }
  }
  
  @override
  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _sharedPreferences.setBool(key, value);
    } catch (e) {
      print('Error saving bool for key $key: $e');
      return false;
    }
  }
  
  @override
  Future<bool?> getBool(String key) async {
    try {
      return _sharedPreferences.getBool(key);
    } catch (e) {
      print('Error getting bool for key $key: $e');
      return null;
    }
  }
  
  @override
  Future<bool> saveInt(String key, int value) async {
    try {
      return await _sharedPreferences.setInt(key, value);
    } catch (e) {
      print('Error saving int for key $key: $e');
      return false;
    }
  }
  
  @override
  Future<int?> getInt(String key) async {
    try {
      return _sharedPreferences.getInt(key);
    } catch (e) {
      print('Error getting int for key $key: $e');
      return null;
    }
  }
  
  @override
  Future<bool> saveDouble(String key, double value) async {
    try {
      return await _sharedPreferences.setDouble(key, value);
    } catch (e) {
      print('Error saving double for key $key: $e');
      return false;
    }
  }
  
  @override
  Future<double?> getDouble(String key) async {
    try {
      return _sharedPreferences.getDouble(key);
    } catch (e) {
      print('Error getting double for key $key: $e');
      return null;
    }
  }
  
  @override
  Future<bool> remove(String key) async {
    try {
      return await _sharedPreferences.remove(key);
    } catch (e) {
      print('Error removing key $key: $e');
      return false;
    }
  }
  
  @override
  Future<bool> containsKey(String key) async {
    try {
      return _sharedPreferences.containsKey(key);
    } catch (e) {
      print('Error checking if key $key exists: $e');
      return false;
    }
  }
}

