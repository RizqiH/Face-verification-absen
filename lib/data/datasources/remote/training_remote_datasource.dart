import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../models/training_model.dart';

abstract class TrainingRemoteDataSource {
  Future<List<TrainingModel>> getTrainings(String? category);
  Future<TrainingModel> getTrainingById(String id);
}

class TrainingRemoteDataSourceImpl implements TrainingRemoteDataSource {
  final DioClient dioClient;

  TrainingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TrainingModel>> getTrainings(String? category) async {
    try {
      final response = await dioClient.dio.get(
        '/trainings',
        queryParameters: category != null ? {'category': category} : null,
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TrainingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get trainings');
    }
  }

  @override
  Future<TrainingModel> getTrainingById(String id) async {
    try {
      final response = await dioClient.dio.get('/trainings/$id');
      return TrainingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get training');
    }
  }
}






