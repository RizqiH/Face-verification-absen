import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends Task {
  TaskModel({
    required super.id,
    @JsonKey(name: 'user_id') required super.userId,
    required super.title,
    super.description,
    required super.status,
    @JsonKey(name: 'due_date') super.dueDate,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}

