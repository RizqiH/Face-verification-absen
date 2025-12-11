import '../../domain/entities/training.dart';

abstract class TrainingRepository {
  Future<List<Training>> getTrainings(String? category);
  Future<Training> getTrainingById(String id);
}






