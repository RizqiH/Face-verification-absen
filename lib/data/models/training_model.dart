import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/training.dart';

part 'training_model.g.dart';

@JsonSerializable()
class TrainingModel extends Training {
  TrainingModel({
    required super.id,
    required super.title,
    super.description,
    super.category,
    super.duration,
    @JsonKey(name: 'image_url') super.imageUrl,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') required super.updatedAt,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) => _$TrainingModelFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingModelToJson(this);
}

