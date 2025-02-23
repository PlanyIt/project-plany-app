import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String content;
  final String userId;
  final String planId;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.planId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      content: json['content'],
      userId: json['userId'],
      planId: json['planId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'userId': userId,
      'planId': planId,
    };
  }
}