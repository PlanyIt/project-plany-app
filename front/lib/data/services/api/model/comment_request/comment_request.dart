import 'package:freezed_annotation/freezed_annotation.dart';
part 'comment_request.freezed.dart';
part 'comment_request.g.dart';

@freezed
class CommentRequest with _$CommentRequest {
  const factory CommentRequest({
    // ignore: invalid_annotation_target
    @JsonKey(name: '_id') String? id,
    required String content,
    required String user,
    required String planId,
    DateTime? createdAt,
    List<String>? likes,
    @Default([]) List<String> responses,
    String? parentId,
    String? imageUrl,
  }) = _CommentRequest;

  factory CommentRequest.fromJson(Map<String, Object?> json) =>
      _$CommentRequestFromJson(json);
}
