import 'dart:io';

import '../../../domain/models/comment/comment.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/imgur_service.dart';
import 'comment_repository.dart';

class CommentRepositoryRemote implements CommentRepository {
  CommentRepositoryRemote(
      {required ApiClient apiClient, required ImgurService imgurService})
      : _apiClient = apiClient,
        _imgurService = imgurService;

  final ApiClient _apiClient;
  final ImgurService _imgurService;

  @override
  Future<Result<List<Comment>>> getComments(String planId,
      {int page = 1, int limit = 10}) async {
    try {
      final result =
          await _apiClient.getComments(planId, page: page, limit: limit);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to load comments: $e'));
    }
  }

  @override
  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    try {
      final result = await _apiClient.getCommentResponses(commentId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to load comment responses: $e'));
    }
  }

  @override
  Future<Result<Comment>> createComment(String planId, Comment comment) async {
    try {
      // Validate input before making the API call
      if (comment.content.trim().isEmpty) {
        return Result.error(Exception('Comment content cannot be empty'));
      }

      if (planId.isEmpty) {
        return Result.error(Exception('Plan ID is required'));
      }

      final result = await _apiClient.createComment(planId, comment);
      return result;
    } catch (e) {
      var errorMessage = 'Failed to create comment';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid comment data. Please check your input.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required. Please log in.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Permission denied.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      return Result.error(Exception('$errorMessage: $e'));
    }
  }

  @override
  Future<Result<void>> editComment(String commentId, Comment comment) async {
    try {
      final result = await _apiClient.editComment(commentId, comment);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to edit comment: $e'));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      final result = await _apiClient.deleteComment(commentId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> getCommentById(String commentId) async {
    try {
      final result = await _apiClient.getCommentById(commentId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to get comment: $e'));
    }
  }

  @override
  Future<Result<void>> likeComment(String commentId) async {
    try {
      final result = await _apiClient.likeComment(commentId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to like comment: $e'));
    }
  }

  @override
  Future<Result<void>> unlikeComment(String commentId) async {
    try {
      final result = await _apiClient.unlikeComment(commentId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to unlike comment: $e'));
    }
  }

  @override
  Future<Result<Comment>> respondToComment(
      String commentId, Comment comment) async {
    try {
      final result = await _apiClient.respondToComment(commentId, comment);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to respond to comment: $e'));
    }
  }

  @override
  Future<Result<void>> deleteResponse(
      String commentId, String responseId) async {
    try {
      final result = await _apiClient.deleteResponse(commentId, responseId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to delete response: $e'));
    }
  }

  @override
  Future<Result<void>> addResponseToComment(
      String commentId, String responseId) async {
    try {
      final result =
          await _apiClient.addResponseToComment(commentId, responseId);
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to add response to comment: $e'));
    }
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    try {
      final imageUrl = await _imgurService.uploadImage(imageFile);
      return Result.ok(imageUrl);
    } catch (e) {
      return Result.error(Exception('Failed to upload image: $e'));
    }
  }
}
