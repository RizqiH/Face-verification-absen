class Training {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final int? duration; // in minutes
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Training({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.duration,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}






