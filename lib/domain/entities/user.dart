import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String position; // Can be empty string, but not null
  final String? profilePhotoUrl;
  final String? companyId;
  final String? companyName;
  
  final String department;
  
  const User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.position,
    this.department = '',
    this.profilePhotoUrl,
    this.companyId,
    this.companyName,
  });
  
  User copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
    String? position,
    String? department,
    String? profilePhotoUrl,
    String? companyId,
    String? companyName,
  }) {
    return User(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      department: department ?? this.department,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    name,
    email,
    position,
    department,
    profilePhotoUrl,
    companyId,
    companyName,
  ];
}

