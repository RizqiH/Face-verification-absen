import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance.dart';

part 'attendance_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake, // Backend uses snake_case (user_id, clock_in, etc)
)
class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.userId,
    super.clockIn,
    super.clockOut,
    required super.createdAt,
    super.clockInPhoto,
    super.clockOutPhoto,
    super.clockInLocation,
    super.clockOutLocation,
    super.isVerified,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);
  
  factory AttendanceModel.fromEntity(Attendance attendance) {
    return AttendanceModel(
      id: attendance.id,
      userId: attendance.userId,
      clockIn: attendance.clockIn,
      clockOut: attendance.clockOut,
      createdAt: attendance.createdAt,
      clockInPhoto: attendance.clockInPhoto,
      clockOutPhoto: attendance.clockOutPhoto,
      clockInLocation: attendance.clockInLocation,
      clockOutLocation: attendance.clockOutLocation,
      isVerified: attendance.isVerified,
    );
  }
}

