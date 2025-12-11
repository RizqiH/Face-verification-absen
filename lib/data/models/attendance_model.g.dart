// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clockIn: json['clock_in'] == null
          ? null
          : DateTime.parse(json['clock_in'] as String),
      clockOut: json['clock_out'] == null
          ? null
          : DateTime.parse(json['clock_out'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      clockInPhoto: json['clock_in_photo'] as String?,
      clockOutPhoto: json['clock_out_photo'] as String?,
      clockInLocation: json['clock_in_location'] as String?,
      clockOutLocation: json['clock_out_location'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'clock_in': instance.clockIn?.toIso8601String(),
      'clock_out': instance.clockOut?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'clock_in_photo': instance.clockInPhoto,
      'clock_out_photo': instance.clockOutPhoto,
      'clock_in_location': instance.clockInLocation,
      'clock_out_location': instance.clockOutLocation,
      'is_verified': instance.isVerified,
    };
