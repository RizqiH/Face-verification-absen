import '../../domain/entities/task.dart';

abstract class TaskRepository {
  Future<Task> createTask(String title, String? description, DateTime? dueDate);
  Future<List<Task>> getTasks(String? status);
  Future<Task> updateTask(String taskId, String? title, String? description, String? status, DateTime? dueDate);
  Future<void> deleteTask(String taskId);
}






