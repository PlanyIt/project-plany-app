class Comment {
  final String? id;
  final String content;
  final String? userId;
  final String planId;
  final DateTime? createdAt;
  List<String>? likes;
  final List<String> responses;
  final String? parentId;
  String? imageUrl;

  Comment({
    this.id,
    required this.content,
    this.userId,
    required this.planId,
    this.createdAt,
    this.likes,
    this.responses = const [],
    this.parentId,
    this.imageUrl,
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
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'content': content,
      'planId': planId,
    };
    
    if (likes != null) data['likes'] = likes;
    if (responses.isNotEmpty) data['responses'] = responses;
    if (parentId != null) data['parentId'] = parentId;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    
    return data;
  }

  Comment copyWith({
    String? id,
    String? content,
    String? userId,
    String? planId,
    DateTime? createdAt,
    List<String>? likes,
    List<String>? responses,
    String? parentId,
    String? imageUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      responses: responses ?? this.responses,
      parentId: parentId ?? this.parentId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}