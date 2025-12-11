import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final String id;
  final String userId;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final DateTime createdAt;
  final String? clockInPhoto;
  final String? clockOutPhoto;
  final String? clockInLocation;
  final String? clockOutLocation;
  final bool isVerified;
  
  const Attendance({
    required this.id,
    required this.userId,
    this.clockIn,
    this.clockOut,
    required this.createdAt,
    this.clockInPhoto,
    this.clockOutPhoto,
    this.clockInLocation,
    this.clockOutLocation,
    this.isVerified = false,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    clockIn,
    clockOut,
    clockInPhoto,
    clockOutPhoto,
    clockInLocation,
    clockOutLocation,
    isVerified,
  ];
}

