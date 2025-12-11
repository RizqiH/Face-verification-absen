part of 'training_bloc.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoading extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final List<Training> trainings;

  const TrainingLoaded({required this.trainings});

  @override
  List<Object?> get props => [trainings];
}

class TrainingDetailLoaded extends TrainingState {
  final Training training;

  const TrainingDetailLoaded({required this.training});

  @override
  List<Object?> get props => [training];
}

class TrainingError extends TrainingState {
  final String message;

  const TrainingError({required this.message});

  @override
  List<Object?> get props => [message];
}






