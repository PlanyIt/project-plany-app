class Comment {
  final String? id;
  final String content;
  final String? userId;
  final String planId;
  final DateTime? createdAt;
  final List<String>? likes;
  final List<String> responses;
  final String? parentId; // Ajouté pour la compatibilité avec le backend

  Comment({
    this.id,
    required this.content,
    this.userId,
    required this.planId,
    this.createdAt,
    this.likes,
    this.responses = const [],
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      content: json['content'],
      userId: json['userId'],
      planId: json['planId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      likes: List<String>.from(json['likes'] ?? []),
      responses: List<String>.from(json['responses'] ?? []),
      parentId: json['parentId'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'content': content,
      'planId': planId,
    };
    
    // Ajoutez ces champs conditionnellement car ils peuvent être null
    if (likes != null) data['likes'] = likes;
    if (responses.isNotEmpty) data['responses'] = responses;
    if (parentId != null) data['parentId'] = parentId;
    // userId et createdAt sont gérés par le backend
    
    return data;
  }
}
