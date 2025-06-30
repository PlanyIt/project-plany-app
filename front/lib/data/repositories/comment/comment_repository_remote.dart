import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/core/utils/result.dart';
import 'package:front/core/utils/exceptions.dart';
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
      // Validate input
      if (planId.isEmpty) {
        _log.warning('getCommentsByPlanId called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      if (page < 1) {
        _log.warning('getCommentsByPlanId called with invalid page: $page');
        return Result.error(
          const ValidationException(
              'Le numéro de page doit être supérieur à 0'),
        );
      }

      if (limit < 1 || limit > 100) {
        _log.warning('getCommentsByPlanId called with invalid limit: $limit');
        return Result.error(
          const ValidationException('La limite doit être entre 1 et 100'),
        );
      }

      _log.info(
          'Getting comments for plan: $planId (page: $page, limit: $limit)');
      final result = await _apiClient.getCommentsByPlanId(planId,
          page: page, limit: limit);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final commentsData = result.value['comments'] as List<dynamic>;
            final comments = commentsData
                .map((json) => Comment.fromJson(json as Map<String, dynamic>))
                .toList();
            _log.info('Successfully fetched ${comments.length} comments');
            return Result.ok(comments);
          } catch (e, stackTrace) {
            _log.severe('Error parsing comments data', e, stackTrace);
            return Result.error(
              const ParseException(
                  'Erreur lors du traitement des commentaires'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to fetch comments: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comments by plan ID', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des commentaires'),
      );
    }
  }

  @override
  Future<Result<Comment>> createComment(Comment comment) async {
    try {
      // Validate input
      if (comment.content.isEmpty) {
        _log.warning('createComment called with empty content');
        return Result.error(
          const ValidationException('Le contenu du commentaire est requis'),
        );
      }

      if (comment.planId.isEmpty) {
        _log.warning('createComment called with empty planId');
        return Result.error(
          const ValidationException('ID du plan requis'),
        );
      }

      _log.info('Creating comment');
      final result = await _apiClient.createComment(comment.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final createdComment = Comment.fromJson(result.value);
            _log.info('Successfully created comment: ${createdComment.id}');
            return Result.ok(createdComment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing created comment data', e, stackTrace);
            return Result.error(
              const ParseException(
                  'Erreur lors du traitement du commentaire créé'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to create comment: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error creating comment', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la création du commentaire'),
      );
    }
  }

  @override
  Future<Result<Comment>> updateComment(
      String commentId, Comment comment) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('updateComment called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      if (comment.content.isEmpty) {
        _log.warning('updateComment called with empty content');
        return Result.error(
          const ValidationException('Le contenu du commentaire est requis'),
        );
      }

      _log.info('Updating comment: $commentId');
      final result =
          await _apiClient.updateComment(commentId, comment.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final updatedComment = Comment.fromJson(result.value);
            _log.info('Successfully updated comment: $commentId');
            return Result.ok(updatedComment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing updated comment data', e, stackTrace);
            return Result.error(
              const ParseException(
                  'Erreur lors du traitement du commentaire mis à jour'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to update comment: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error updating comment', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la mise à jour du commentaire'),
      );
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('deleteComment called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      _log.info('Deleting comment: $commentId');
      final result = await _apiClient.deleteComment(commentId);

      switch (result) {
        case Ok<void>():
          _log.info('Successfully deleted comment: $commentId');
          return result;
        case Error<void>():
          _log.warning('Failed to delete comment: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Error deleting comment', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la suppression du commentaire'),
      );
    }
  }

  @override
  Future<Result<Comment>> getCommentById(String commentId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('getCommentById called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      _log.info('Getting comment: $commentId');
      final result = await _apiClient.getCommentById(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final comment = Comment.fromJson(result.value);
            _log.info('Successfully fetched comment: $commentId');
            return Result.ok(comment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing comment data', e, stackTrace);
            return Result.error(
              const ParseException('Erreur lors du traitement du commentaire'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to fetch comment: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comment by ID', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération du commentaire'),
      );
    }
  }

  @override
  Future<Result<Comment>> likeComment(String commentId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('likeComment called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      _log.info('Liking comment: $commentId');
      final result = await _apiClient.likeComment(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final comment = Comment.fromJson(result.value);
            _log.info('Successfully liked comment: $commentId');
            return Result.ok(comment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing liked comment data', e, stackTrace);
            return Result.error(
              const ParseException('Erreur lors du traitement du like'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to like comment: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error liking comment', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors du like du commentaire'),
      );
    }
  }

  @override
  Future<Result<Comment>> unlikeComment(String commentId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('unlikeComment called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      _log.info('Unliking comment: $commentId');
      final result = await _apiClient.unlikeComment(commentId);

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final comment = Comment.fromJson(result.value);
            _log.info('Successfully unliked comment: $commentId');
            return Result.ok(comment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing unliked comment data', e, stackTrace);
            return Result.error(
              const ParseException('Erreur lors du traitement du unlike'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to unlike comment: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error unliking comment', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors du unlike du commentaire'),
      );
    }
  }

  @override
  Future<Result<Comment>> addCommentResponse(
      String commentId, Comment response) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('addCommentResponse called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      if (response.content.isEmpty) {
        _log.warning('addCommentResponse called with empty response content');
        return Result.error(
          const ValidationException('Le contenu de la réponse est requis'),
        );
      }

      _log.info('Adding response to comment: $commentId');
      final result =
          await _apiClient.addCommentResponse(commentId, response.toJson());

      switch (result) {
        case Ok<Map<String, dynamic>>():
          try {
            final responseComment = Comment.fromJson(result.value);
            _log.info('Successfully added response to comment: $commentId');
            return Result.ok(responseComment);
          } catch (e, stackTrace) {
            _log.severe('Error parsing comment response data', e, stackTrace);
            return Result.error(
              const ParseException('Erreur lors du traitement de la réponse'),
            );
          }
        case Error<Map<String, dynamic>>():
          _log.warning('Failed to add comment response: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error adding comment response', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de l\'ajout de la réponse'),
      );
    }
  }

  @override
  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('getCommentResponses called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      _log.info('Getting responses for comment: $commentId');
      final result = await _apiClient.getCommentResponses(commentId);

      switch (result) {
        case Ok<List<Map<String, dynamic>>>():
          try {
            final responses =
                result.value.map((json) => Comment.fromJson(json)).toList();
            _log.info('Successfully fetched ${responses.length} responses');
            return Result.ok(responses);
          } catch (e, stackTrace) {
            _log.severe('Error parsing comment responses data', e, stackTrace);
            return Result.error(
              const ParseException('Erreur lors du traitement des réponses'),
            );
          }
        case Error<List<Map<String, dynamic>>>():
          _log.warning('Failed to fetch comment responses: ${result.error}');
          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Error getting comment responses', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des réponses'),
      );
    }
  }

  @override
  Future<Result<void>> removeCommentResponse(
      String commentId, String responseId) async {
    try {
      // Validate input
      if (commentId.isEmpty) {
        _log.warning('removeCommentResponse called with empty commentId');
        return Result.error(
          const ValidationException('ID du commentaire requis'),
        );
      }

      if (responseId.isEmpty) {
        _log.warning('removeCommentResponse called with empty responseId');
        return Result.error(
          const ValidationException('ID de la réponse requis'),
        );
      }

      _log.info('Removing response $responseId from comment: $commentId');
      final result =
          await _apiClient.removeCommentResponse(commentId, responseId);

      switch (result) {
        case Ok<void>():
          _log.info(
              'Successfully removed response $responseId from comment: $commentId');
          return result;
        case Error<void>():
          _log.warning('Failed to remove comment response: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe('Error removing comment response', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la suppression de la réponse'),
      );
    }
  }
}
