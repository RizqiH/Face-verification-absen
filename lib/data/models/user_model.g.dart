// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      position: json['position'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      companyId: json['companyId'] as String?,
      companyName: json['companyName'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'name': instance.name,
      'email': instance.email,
      'position': instance.position,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'companyId': instance.companyId,
      'companyName': instance.companyName,
    };
