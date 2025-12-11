part of 'attendance_bloc.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final Attendance? attendance;
  
  const AttendanceLoaded({this.attendance});
  
  @override
  List<Object?> get props => [attendance];
}

class AttendanceSuccess extends AttendanceState {
  final Attendance attendance;
  
  const AttendanceSuccess({required this.attendance});
  
  @override
  List<Object> get props => [attendance];
}

class AttendanceHistoryLoading extends AttendanceState {
  final List<Attendance>? previousHistory;
  final Attendance? todayAttendance;
  
  const AttendanceHistoryLoading({
    this.previousHistory,
    this.todayAttendance,
  });
  
  @override
  List<Object?> get props => [previousHistory, todayAttendance];
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<Attendance> history;
  final Attendance? todayAttendance;
  
  const AttendanceHistoryLoaded({
    required this.history,
    this.todayAttendance,
  });
  
  @override
  List<Object?> get props => [history, todayAttendance];
}

class AttendanceError extends AttendanceState {
  final String message;
  
  const AttendanceError({required this.message});
  
  @override
  List<Object> get props => [message];
}

