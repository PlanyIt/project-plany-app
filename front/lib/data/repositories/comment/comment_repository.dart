import 'dart:io';

import '../../../domain/models/comment/comment.dart';
import '../../../utils/result.dart';

abstract class CommentRepository {
  /// Get comments for a plan with pagination
  Future<Result<List<Comment>>> getComments(String planId,
      {int page = 1, int limit = 10});

  /// Get responses for a comment
  Future<Result<List<Comment>>> getCommentResponses(String commentId);

  /// Create a new comment
  Future<Result<Comment>> createComment(String planId, Comment comment);

  /// Edit an existing comment
  Future<Result<void>> editComment(String commentId, Comment comment);

  /// Delete a comment
  Future<Result<void>> deleteComment(String commentId);

  /// Get comment by ID
  Future<Result<Comment>> getCommentById(String commentId);

  /// Like a comment
  Future<Result<void>> likeComment(String commentId);

  /// Unlike a comment
  Future<Result<void>> unlikeComment(String commentId);

  /// Respond to a comment
  Future<Result<Comment>> respondToComment(String commentId, Comment comment);

  /// Delete a response
  Future<Result<void>> deleteResponse(String commentId, String responseId);

  /// Add response to comment
  Future<Result<void>> addResponseToComment(
      String commentId, String responseId);

  /// Uploads an image for a [Comment].
  Future<Result<String>> uploadImage(File imageFile);
}
