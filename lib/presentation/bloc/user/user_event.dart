part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends UserEvent {
  final String name;
  final String? position;
  final String? department;

  const UpdateProfileEvent({
    required this.name,
    this.position,
    this.department,
  });

  @override
  List<Object?> get props => [name, position, department];
}

class ChangePasswordEvent extends UserEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

class UploadProfilePhotoEvent extends UserEvent {
  final String photoPath;

  const UploadProfilePhotoEvent({required this.photoPath});

  @override
  List<Object?> get props => [photoPath];
}



