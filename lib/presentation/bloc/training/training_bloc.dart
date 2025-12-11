import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/training.dart';
import '../../../domain/repositories/training_repository.dart';

part 'training_event.dart';
part 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final TrainingRepository trainingRepository;

  TrainingBloc({required this.trainingRepository}) : super(TrainingInitial()) {
    on<GetTrainingsEvent>(_onGetTrainings);
    on<GetTrainingByIdEvent>(_onGetTrainingById);
  }

  Future<void> _onGetTrainings(GetTrainingsEvent event, Emitter<TrainingState> emit) async {
    emit(TrainingLoading());
    try {
      final trainings = await trainingRepository.getTrainings(event.category);
      emit(TrainingLoaded(trainings: trainings));
    } catch (e) {
      emit(TrainingError(message: e.toString()));
    }
  }

  Future<void> _onGetTrainingById(GetTrainingByIdEvent event, Emitter<TrainingState> emit) async {
    emit(TrainingLoading());
    try {
      final training = await trainingRepository.getTrainingById(event.id);
      emit(TrainingDetailLoaded(training: training));
    } catch (e) {
      emit(TrainingError(message: e.toString()));
    }
  }
}






