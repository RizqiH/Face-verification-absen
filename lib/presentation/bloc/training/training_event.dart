part of 'training_bloc.dart';

abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object?> get props => [];
}

class GetTrainingsEvent extends TrainingEvent {
  final String? category;

  const GetTrainingsEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class GetTrainingByIdEvent extends TrainingEvent {
  final String id;

  const GetTrainingByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}






