part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTasksEvent extends TaskEvent {
  final String? status;

  const GetTasksEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String? description;
  final DateTime? dueDate;

  const CreateTaskEvent({
    required this.title,
    this.description,
    this.dueDate,
  });

  @override
  List<Object?> get props => [title, description, dueDate];
}

class UpdateTaskEvent extends TaskEvent {
  final String taskId;
  final String? title;
  final String? description;
  final String? status;
  final DateTime? dueDate;

  const UpdateTaskEvent({
    required this.taskId,
    this.title,
    this.description,
    this.status,
    this.dueDate,
  });

  @override
  List<Object?> get props => [taskId, title, description, status, dueDate];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}






