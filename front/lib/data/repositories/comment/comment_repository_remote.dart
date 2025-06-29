import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';
import 'comment_repository.dart';

class CommentRepositoryRemote implements CommentRepository {
  CommentRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('CommentRepositoryRemote');

  @override
  Future<Result<List<Comment>>> getCommentsByPlanId(String planId,
      {int page = 1, int limit = 10}) async {
    try {
      _log.info('Getting comments for plan: $planId');
      final result = await _apiClient.getCommentsByPlanId(planId,
          page: page, limit: limit);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final commentsData = result.value['comments'] as List<dynamic>;
          final comments = commentsData
              .map((json) => Comment.fromJson(json as Map<String, dynamic>))
              .toList();
          return Result.ok(comments);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comments by plan ID', e, stackTrace);
      return Result.error(Exception('Failed to get comments: $e'));
    }
  }

  @override
  Future<Result<Comment>> createComment(Comment comment) async {
    try {
      _log.info('Creating comment');
      final result = await _apiClient.createComment(comment.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final createdComment = Comment.fromJson(result.value);
          return Result.ok(createdComment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error creating comment', e, stackTrace);
      return Result.error(Exception('Failed to create comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> updateComment(
      String commentId, Comment comment) async {
    try {
      _log.info('Updating comment: $commentId');
      final result =
          await _apiClient.updateComment(commentId, comment.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final updatedComment = Comment.fromJson(result.value);
          return Result.ok(updatedComment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating comment', e, stackTrace);
      return Result.error(Exception('Failed to update comment: $e'));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      _log.info('Deleting comment: $commentId');
      return await _apiClient.deleteComment(commentId);
    } catch (e, stackTrace) {
      _log.severe('Error deleting comment', e, stackTrace);
      return Result.error(Exception('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> getCommentById(String commentId) async {
    try {
      _log.info('Getting comment: $commentId');
      final result = await _apiClient.getCommentById(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final comment = Comment.fromJson(result.value);
          return Result.ok(comment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comment by ID', e, stackTrace);
      return Result.error(Exception('Failed to get comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> likeComment(String commentId) async {
    try {
      _log.info('Liking comment: $commentId');
      final result = await _apiClient.likeComment(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final comment = Comment.fromJson(result.value);
          return Result.ok(comment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error liking comment', e, stackTrace);
      return Result.error(Exception('Failed to like comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> unlikeComment(String commentId) async {
    try {
      _log.info('Unliking comment: $commentId');
      final result = await _apiClient.unlikeComment(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final comment = Comment.fromJson(result.value);
          return Result.ok(comment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error unliking comment', e, stackTrace);
      return Result.error(Exception('Failed to unlike comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> addCommentResponse(
      String commentId, Comment response) async {
    try {
      _log.info('Adding response to comment: $commentId');
      final result =
          await _apiClient.addCommentResponse(commentId, response.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          final responseComment = Comment.fromJson(result.value);
          return Result.ok(responseComment);
        case Error<Map<String, dynamic>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error adding comment response', e, stackTrace);
      return Result.error(Exception('Failed to add comment response: $e'));
    }
  }

  @override
  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    try {
      _log.info('Getting responses for comment: $commentId');
      final result = await _apiClient.getCommentResponses(commentId);

      switch (result) {
        case Ok<List<Map<String, dynamic>>>():
          final responses =
              result.value.map((json) => Comment.fromJson(json)).toList();
          return Result.ok(responses);
        case Error<List<Map<String, dynamic>>>():
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comment responses', e, stackTrace);
      return Result.error(Exception('Failed to get comment responses: $e'));
    }
  }

  @override
  Future<Result<void>> removeCommentResponse(
      String commentId, String responseId) async {
    try {
      _log.info('Removing response $responseId from comment: $commentId');
      return await _apiClient.removeCommentResponse(commentId, responseId);
    } catch (e, stackTrace) {
      _log.severe('Error removing comment response', e, stackTrace);
      return Result.error(Exception('Failed to remove comment response: $e'));
    }
  }
}
