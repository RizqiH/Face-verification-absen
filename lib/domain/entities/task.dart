class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status; // pending, in_progress, completed
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });
}






