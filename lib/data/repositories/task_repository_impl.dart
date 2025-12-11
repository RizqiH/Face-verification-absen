import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/remote/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Task> createTask(String title, String? description, DateTime? dueDate) {
    return remoteDataSource.createTask(title, description, dueDate);
  }

  @override
  Future<List<Task>> getTasks(String? status) {
    return remoteDataSource.getTasks(status);
  }

  @override
  Future<Task> updateTask(String taskId, String? title, String? description, String? status, DateTime? dueDate) {
    return remoteDataSource.updateTask(taskId, title, description, status, dueDate);
  }

  @override
  Future<void> deleteTask(String taskId) {
    return remoteDataSource.deleteTask(taskId);
  }
}






