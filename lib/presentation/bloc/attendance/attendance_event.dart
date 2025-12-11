part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  
  @override
  List<Object> get props => [];
}

class ClockInEvent extends AttendanceEvent {
  final String photoPath;
  final String location;
  final String userId;
  
  const ClockInEvent({
    required this.photoPath,
    required this.location,
    required this.userId,
  });
  
  @override
  List<Object> get props => [photoPath, location, userId];
}

class ClockOutEvent extends AttendanceEvent {
  final String photoPath;
  final String location;
  
  const ClockOutEvent({
    required this.photoPath,
    required this.location,
  });
  
  @override
  List<Object> get props => [photoPath, location];
}

class GetTodayAttendanceEvent extends AttendanceEvent {}

class GetHistoryEvent extends AttendanceEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetHistoryEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

