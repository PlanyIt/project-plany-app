class Plan {
  final String? id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String? userId;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> steps;

  Plan({
    this.id,
    required this.title,
    required this.description,
    this.userId,
    required this.steps,
    required this.category,
    this.tags = const [],
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      steps: List<String>.from(json['steps'] ?? []),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'category': category,
      'tags': tags,
      'isPublic': isPublic,
      'steps': steps,
    };
  }
}
