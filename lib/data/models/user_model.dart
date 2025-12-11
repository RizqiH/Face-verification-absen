import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.employeeId,
    required super.name,
    required super.email,
    required super.position,
    super.profilePhotoUrl,
    super.companyId,
    super.companyName,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle null/empty values and snake_case to camelCase conversion
    // Helper function to safely get string value
    String? getStringValue(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      return str.isEmpty ? null : str;
    }
    
    // Helper function to get non-null string with default
    String getRequiredString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      final str = value.toString();
      return str.isEmpty ? defaultValue : str;
    }
    
    return UserModel(
      id: getRequiredString(json['id']),
      employeeId: getRequiredString(
        json['employee_id'] ?? json['employeeId'],
      ),
      name: getRequiredString(json['name']),
      email: getRequiredString(json['email']),
      position: getRequiredString(json['position']),
      profilePhotoUrl: getStringValue(json['profile_photo_url'] ?? json['profilePhotoUrl']),
      companyId: getStringValue(json['company_id'] ?? json['companyId']),
      companyName: getStringValue(json['company_name'] ?? json['companyName']),
    );
  }
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      employeeId: user.employeeId,
      name: user.name,
      email: user.email,
      position: user.position,
      profilePhotoUrl: user.profilePhotoUrl,
      companyId: user.companyId,
      companyName: user.companyName,
    );
  }
}

