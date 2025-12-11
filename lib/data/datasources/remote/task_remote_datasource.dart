import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskModel> createTask(String title, String? description, DateTime? dueDate);
  Future<List<TaskModel>> getTasks(String? status);
  Future<TaskModel> updateTask(String taskId, String? title, String? description, String? status, DateTime? dueDate);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient dioClient;

  TaskRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<TaskModel> createTask(String title, String? description, DateTime? dueDate) async {
    try {
      final response = await dioClient.dio.post(
        '/tasks',
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
        },
      );
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create task');
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String? status) async {
    try {
      final response = await dioClient.dio.get(
        '/tasks',
        queryParameters: status != null ? {'status': status} : null,
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get tasks');
    }
  }

  @override
  Future<TaskModel> updateTask(String taskId, String? title, String? description, String? status, DateTime? dueDate) async {
    try {
      final response = await dioClient.dio.put(
        '/tasks/$taskId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (status != null) 'status': status,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
        },
      );
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await dioClient.dio.delete('/tasks/$taskId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete task');
    }
  }
}






