import '../../domain/entities/training.dart';
import '../../domain/repositories/training_repository.dart';
import '../datasources/remote/training_remote_datasource.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  final TrainingRemoteDataSource remoteDataSource;

  TrainingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Training>> getTrainings(String? category) {
    return remoteDataSource.getTrainings(category);
  }

  @override
  Future<Training> getTrainingById(String id) {
    return remoteDataSource.getTrainingById(id);
  }
}






