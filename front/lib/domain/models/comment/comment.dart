import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    @JsonKey(name: '_id') String? id,
    required String content,
    String? userId,
    required String planId,
    DateTime? createdAt,
    @Default([]) List<String> likes,
    @Default([]) List<String> responses,
    String? parentId,
    String? imageUrl,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}
