import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/usecases/attendance/clock_in_usecase.dart';
import '../../../domain/repositories/attendance_repository.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ClockInUseCase clockInUseCase;
  final AttendanceRepository attendanceRepository;
  
  AttendanceBloc({
    required this.clockInUseCase,
    required this.attendanceRepository,
  }) : super(AttendanceInitial()) {
    on<ClockInEvent>(_onClockIn);
    on<ClockOutEvent>(_onClockOut);
    on<GetTodayAttendanceEvent>(_onGetTodayAttendance);
    on<GetHistoryEvent>(_onGetHistory);
  }
  
  Future<void> _onClockIn(ClockInEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final attendance = await clockInUseCase.execute(
        event.photoPath,
        event.location,
        event.userId,
      );
      // Emit success state - this will trigger navigation and snackbar
      emit(AttendanceSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: e.toString()));
    }
  }
  
  Future<void> _onClockOut(ClockOutEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final attendance = await attendanceRepository.clockOut(
        event.photoPath,
        event.location,
      );
      emit(AttendanceSuccess(attendance: attendance));
    } catch (e) {
      emit(AttendanceError(message: e.toString()));
    }
  }
  
  Future<void> _onGetTodayAttendance(
    GetTodayAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    print('DEBUG: _onGetTodayAttendance - Event received');
    emit(AttendanceLoading());
    try {
      print('DEBUG: Calling attendanceRepository.getTodayAttendance()');
      final attendance = await attendanceRepository.getTodayAttendance();
      print('DEBUG: Attendance result: ${attendance != null ? "Found" : "Null"}');
      // Always emit loaded state, even if attendance is null
      // This prevents infinite loading
      emit(AttendanceLoaded(attendance: attendance));
    } catch (e) {
      print('DEBUG: Error in getTodayAttendance: $e');
      // On error, emit loaded state with null attendance instead of error
      // This allows the UI to still render and show empty state
      emit(AttendanceLoaded(attendance: null));
    }
  }

  Future<void> _onGetHistory(
    GetHistoryEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    // Preserve current state
    Attendance? todayAttendance;
    List<Attendance>? previousHistory;
    final currentState = state;
    
    if (currentState is AttendanceLoaded) {
      todayAttendance = currentState.attendance;
    } else if (currentState is AttendanceHistoryLoaded) {
      todayAttendance = currentState.todayAttendance;
      previousHistory = currentState.history;
    } else if (currentState is AttendanceHistoryLoading) {
      todayAttendance = currentState.todayAttendance;
      previousHistory = currentState.previousHistory;
    }
    
    // Emit loading state with previous data preserved
    emit(AttendanceHistoryLoading(
      previousHistory: previousHistory,
      todayAttendance: todayAttendance,
    ));
    
    try {
      final history = await attendanceRepository.getAttendanceHistory(event.startDate, event.endDate);
      // Always emit loaded state, even if history is empty
      // This prevents infinite loading
      emit(AttendanceHistoryLoaded(
        history: history,
        todayAttendance: todayAttendance,
      ));
    } catch (e) {
      // If error, preserve previous state with today attendance
      if (todayAttendance != null) {
        if (previousHistory != null) {
          emit(AttendanceHistoryLoaded(
            history: previousHistory,
            todayAttendance: todayAttendance,
          ));
        } else {
          emit(AttendanceLoaded(attendance: todayAttendance));
        }
      } else {
        emit(AttendanceError(message: e.toString()));
      }
    }
  }
}

