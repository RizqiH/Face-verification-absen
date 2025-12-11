import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<GetTasksEvent>(_onGetTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onGetTasks(GetTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await taskRepository.getTasks(event.status);
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = await taskRepository.createTask(event.title, event.description, event.dueDate);
      final currentState = state;
      if (currentState is TaskLoaded) {
        emit(TaskLoaded(tasks: [task, ...currentState.tasks]));
      } else {
        emit(TaskLoaded(tasks: [task]));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final updatedTask = await taskRepository.updateTask(
        event.taskId,
        event.title,
        event.description,
        event.status,
        event.dueDate,
      );
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = currentState.tasks.map((t) => t.id == event.taskId ? updatedTask : t).toList();
        emit(TaskLoaded(tasks: updatedTasks));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await taskRepository.deleteTask(event.taskId);
      final currentState = state;
      if (currentState is TaskLoaded) {
        final updatedTasks = currentState.tasks.where((t) => t.id != event.taskId).toList();
        emit(TaskLoaded(tasks: updatedTasks));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}






