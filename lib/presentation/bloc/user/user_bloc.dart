import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/face_recognition_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../auth/auth_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  UserBloc({
    required this.userRepository,
    required this.authBloc,
  }) : super(UserInitial()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UploadProfilePhotoEvent>(_onUploadProfilePhoto);
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final updatedUser = await userRepository.updateProfile(event.name, event.position);
      authBloc.add(UpdateUserEvent(user: updatedUser));
      emit(UserSuccess(message: 'Profil berhasil diperbarui'));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await userRepository.changePassword(event.oldPassword, event.newPassword);
      emit(UserSuccess(message: 'Password berhasil diubah'));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUploadProfilePhoto(UploadProfilePhotoEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      // Wait a bit to ensure AuthBloc state is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      final currentState = authBloc.state;
      print('DEBUG: UserBloc - Auth state type: ${currentState.runtimeType}');
      
      if (currentState is! AuthAuthenticated) {
        print('ERROR: UserBloc - User not authenticated, current state: $currentState');
        throw Exception('Anda harus login terlebih dahulu');
      }
      
      final userId = currentState.user.id;
      print('DEBUG: UserBloc - User ID: $userId');
      
      // STEP 1: Upload to face recognition service FIRST (extract embedding)
      final faceRecognitionRepo = sl<FaceRecognitionRepository>();
      await faceRecognitionRepo.uploadProfilePhoto(event.photoPath, userId);
      
      // STEP 2: Upload to backend (for display)
      final photoUrl = await userRepository.uploadProfilePhoto(event.photoPath);
      
      // STEP 3: Update user state with new photo URL
      // Save original URL without cache buster to prevent URL changes on app resume
      // Cache buster should only be added at widget level if needed, not stored in state
      final updatedUser = currentState.user.copyWith(profilePhotoUrl: photoUrl);
      authBloc.add(UpdateUserEvent(user: updatedUser));
      
      emit(UserSuccess(message: 'Foto profil berhasil diubah'));
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('No face detected') || errorMsg.contains('face embedding')) {
        emit(UserError(message: 'Tidak ada wajah terdeteksi di foto. Pastikan wajah Anda terlihat jelas.'));
      } else {
        emit(UserError(message: 'Gagal mengupload foto: $errorMsg'));
      }
    }
  }
}





