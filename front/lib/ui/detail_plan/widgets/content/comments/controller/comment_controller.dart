import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:front/domain/models/comment.dart';
import 'package:front/domain/models/imgur_response.dart';
import 'package:front/services/comment_service.dart';
import 'package:front/services/imgur_service.dart';

class CommentController extends ChangeNotifier {
  final String planId;
  final BuildContext context;
  final Function(int)? onCommentCountChanged;

  final CommentService _commentService = CommentService();
  final ImgurService _imgurService = ImgurService();

  List<Comment> comments = [];
  Map<String, List<Comment>> responses = {};
  Map<String, bool> showAllResponsesMap = {};
  String? currentUserId;

  bool hasMoreComments = true;

  File? selectedImage;
  File? selectedResponseImage;
  String? existingImageUrl;
  bool isUploadingImage = false;
  bool isUploadingResponseImage = false;

  CommentController({
    required this.planId,
    required this.context,
    this.onCommentCountChanged,
    this.currentUserId,
  });

  void updateCurrentUserId(String? userId) {
    currentUserId = userId;
  }

  Future<List<Comment>> loadComments(
      {bool reset = false, int currentPage = 1, int pageLimit = 10}) async {
    try {
      final commentsData = await _commentService.getComments(
        planId,
        page: currentPage,
        limit: pageLimit,
      );

      if (commentsData.length < pageLimit) {
        hasMoreComments = false;
      }

      if (reset) {
        comments = commentsData;
      } else {
        comments.addAll(commentsData);
      }

      if (onCommentCountChanged != null) {
        onCommentCountChanged!(comments.length);
      }

      for (final comment in commentsData) {
        if (comment.id != null && comment.responses.isNotEmpty) {
          loadResponses(comment.id!);
        }
      }

      return commentsData;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des commentaires : $e')),
      );
      print('Erreur lors du chargement des commentaires : $e');
      rethrow;
    }
  }

  Future<void> loadResponses(String commentId) async {
    try {
      if (responses.containsKey(commentId)) return;

      final comment = comments.firstWhere((c) => c.id == commentId);
      if (comment.responses.isEmpty) {
        responses[commentId] = [];
        return;
      }

      List<Comment> commentResponses = [];
      for (String responseId in comment.responses) {
        try {
          final response = await _commentService.getCommentById(responseId);
          commentResponses.add(response);
        } catch (e) {
          print('Erreur lors du chargement de la réponse $responseId : $e');
        }
      }

      responses[commentId] = commentResponses;
    } catch (e) {
      print('Erreur lors du chargement des réponses pour $commentId : $e');
    }
  }

  Future<Comment?> saveComment(String content) async {
    bool hasText = content.trim().isNotEmpty;
    bool hasImage = selectedImage != null || existingImageUrl != null;

    if (!hasText && !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter un texte ou une image")),
      );
      return null;
    }

    String? imageUrl;
    if (selectedImage != null) {
      imageUrl = await uploadImage(selectedImage!);
    } else if (existingImageUrl != null) {
      imageUrl = existingImageUrl;
    }

    try {
      final newComment = Comment(
        content: content.trim(),
        planId: planId,
        imageUrl: imageUrl,
      );

      final createdComment =
          await _commentService.createComment(planId, newComment);

      comments.insert(0, createdComment);

      if (onCommentCountChanged != null) {
        onCommentCountChanged!(comments.length);
      }

      Fluttertoast.showToast(msg: 'Commentaire ajouté avec succès');

      return createdComment;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
      return null;
    }
  }

  Future<Comment?> editComment(String commentId, String content,
      {File? newImage}) async {
    Comment? commentToEdit;
    bool isResponse = false;
    String? parentCommentId;

    try {
      commentToEdit = comments.firstWhere((comment) => comment.id == commentId);
    } catch (e) {
      for (var parentId in responses.keys) {
        try {
          commentToEdit = responses[parentId]!
              .firstWhere((response) => response.id == commentId);
          isResponse = true;
          parentCommentId = parentId;
          break;
        } catch (e) {
          // Continue searching
        }
      }
    }

    if (commentToEdit == null) return null;

    String? finalImageUrl;
    if (newImage != null) {
      finalImageUrl = await uploadImage(newImage);
    } else if (existingImageUrl != null) {
      finalImageUrl = existingImageUrl;
    }

    final updatedComment = Comment(
      id: commentId,
      content: content.trim(),
      userId: commentToEdit.userId,
      planId: planId,
      createdAt: commentToEdit.createdAt,
      likes: commentToEdit.likes,
      responses: commentToEdit.responses,
      parentId: commentToEdit.parentId,
      imageUrl: finalImageUrl,
    );

    await _commentService.editComment(commentId, updatedComment);

    if (isResponse && parentCommentId != null) {
      final index =
          responses[parentCommentId]!.indexWhere((r) => r.id == commentId);
      if (index != -1) {
        responses[parentCommentId]![index] = updatedComment;
      }
    } else {
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = updatedComment;
      }
    }

    Fluttertoast.showToast(msg: 'Commentaire modifié avec succès');

    return updatedComment;
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);

      final index = comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        comments.removeAt(index);

        if (responses.containsKey(commentId)) {
          responses.remove(commentId);
        }

        if (onCommentCountChanged != null) {
          onCommentCountChanged!(comments.length);
        }
      }

      Fluttertoast.showToast(
          msg: 'Commentaire et ses réponses supprimés avec succès');
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
      return false;
    }
  }

  Future<Comment?> saveResponse(String commentId, String content) async {
    bool hasText = content.trim().isNotEmpty;
    bool hasImage = selectedResponseImage != null || existingImageUrl != null;

    if (!hasText && !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter un texte ou une image")),
      );
      return null;
    }

    String? imageUrl;
    if (selectedResponseImage != null) {
      imageUrl = await uploadImage(selectedResponseImage!);
    } else if (existingImageUrl != null) {
      imageUrl = existingImageUrl;
    }

    try {
      final response = Comment(
        content: content.trim(),
        planId: planId,
        parentId: commentId,
        imageUrl: imageUrl,
      );

      final createdResponse =
          await _commentService.createComment(planId, response);
      await _commentService.respondToComment(commentId, createdResponse);

      if (!responses.containsKey(commentId)) {
        responses[commentId] = [];
      }
      responses[commentId]!.add(createdResponse);

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index].responses.add(createdResponse.id!);
      }

      showAllResponsesMap[commentId] = true;

      Fluttertoast.showToast(msg: 'Réponse ajoutée avec succès');
      return createdResponse;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
      return null;
    }
  }

  Future<bool> deleteResponse(String commentId, String responseId) async {
    try {
      await _commentService.deleteResponse(commentId, responseId);

      if (responses.containsKey(commentId)) {
        responses[commentId]?.removeWhere((r) => r.id == responseId);
      }

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index].responses.removeWhere((id) => id == responseId);
      }

      Fluttertoast.showToast(msg: 'Réponse supprimée avec succès');
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la suppression de la réponse : $e')),
      );
      return false;
    }
  }

  Future<bool> toggleLike(Comment comment, bool isLiked) async {
    try {
      if (isLiked) {
        await _commentService.unlikeComment(comment.id!);
        comment.likes?.remove(currentUserId);
      } else {
        await _commentService.likeComment(comment.id!);
        comment.likes ??= [];
        comment.likes?.add(currentUserId!);
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du like/unlike: $e')),
      );
      return false;
    }
  }

  void removeImage() {
    selectedImage = null;
    existingImageUrl = null;
  }

  void removeResponseImage() {
    selectedResponseImage = null;
    existingImageUrl = null;
  }

  Future<String?> uploadImage(File imageFile) async {
    isUploadingImage = true;

    try {
      ImgurResponse response = await _imgurService.uploadImage(imageFile);
      return response.link;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'upload: $e")),
      );
      return null;
    } finally {
      isUploadingImage = false;
    }
  }

  String formatTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 8) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}j';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }

  CommentResult? findCommentById(String commentId) {
    try {
      final comment = comments.firstWhere((c) => c.id == commentId);
      return CommentResult(comment, false, null);
    } catch (e) {
      for (var parentId in responses.keys) {
        try {
          final response =
              responses[parentId]!.firstWhere((r) => r.id == commentId);
          return CommentResult(response, true, parentId);
        } catch (e) {
          // Continue searching
        }
      }
    }
    return null;
  }

  void pickImageWithFile(File imageFile) {
    selectedImage = imageFile;
    notifyListeners();
  }
}

// Classe helper pour retourner un commentaire avec son contexte
class CommentResult {
  final Comment comment;
  final bool isResponse;
  final String? parentCommentId;

  CommentResult(this.comment, this.isResponse, this.parentCommentId);
}
