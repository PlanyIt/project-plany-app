import 'package:freezed_annotation/freezed_annotation.dart';
import '../user/user.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    @JsonKey(name: '_id') String? id,
    required String content,
    User? user,
    required String planId,
    DateTime? createdAt,
    List<String>? likes,
    @Default([]) List<String> responses,
    String? parentId,
    String? imageUrl,
  }) = _Comment;

  factory Comment.fromJson(Map<String, Object?> json) =>
      _$CommentFromJson(json);
}
