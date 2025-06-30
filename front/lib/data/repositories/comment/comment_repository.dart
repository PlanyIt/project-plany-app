import 'package:front/domain/models/comment/comment.dart';
import 'package:front/core/utils/result.dart';

abstract class CommentRepository {
  Future<Result<List<Comment>>> getCommentsByPlanId(String planId,
      {int page = 1, int limit = 10});
  Future<Result<Comment>> createComment(Comment comment);
  Future<Result<Comment>> updateComment(String commentId, Comment comment);
  Future<Result<void>> deleteComment(String commentId);
  Future<Result<Comment>> getCommentById(String commentId);
  Future<Result<Comment>> likeComment(String commentId);
  Future<Result<Comment>> unlikeComment(String commentId);
  Future<Result<Comment>> addCommentResponse(
      String commentId, Comment response);
  Future<Result<List<Comment>>> getCommentResponses(String commentId);
  Future<Result<void>> removeCommentResponse(
      String commentId, String responseId);
}
