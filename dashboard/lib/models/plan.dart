class Plan {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String userId;
  final List<String> steps;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? viewCount;
  final int? likeCount;
  final int? saveCount;

  Plan({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.userId,
    required this.steps,
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
    this.viewCount,
    this.likeCount,
    this.saveCount,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      userId: json['userId'],
      steps: List<String>.from(json['steps'] ?? []),
      isPublic: json['isPublic'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      viewCount: json['viewCount'],
      likeCount: json['likeCount'],
      saveCount: json['saveCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'userId': userId,
      'steps': steps,
      'isPublic': isPublic,
    };
  }

  Plan copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? userId,
    List<String>? steps,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    int? saveCount,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      steps: steps ?? this.steps,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      saveCount: saveCount ?? this.saveCount,
    );
  }
}
