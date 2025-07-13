import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/comment/comment_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../domain/models/comment/comment.dart';
import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';

class CommentViewModel extends ChangeNotifier {
  CommentViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CommentRepository commentRepository,
    required this.planId,
    this.onCommentCountChanged,
    User? currentUserId,
  })  : _commentRepository = commentRepository,
        _userRepository = userRepository,
        _currentUser = currentUserId;

  final CommentRepository _commentRepository;
  final UserRepository _userRepository;

  final String planId;
  final Function(int)? onCommentCountChanged;

  // State
  List<Comment> _comments = [];
  final Map<String, List<Comment>> _responses = {};
  final Map<String, bool> _showAllResponsesMap = {};
  final User? _currentUser;
  bool _hasMoreComments = true;
  File? _selectedImage;
  File? _selectedResponseImage;
  String? _existingImageUrl;
  final bool _isUploadingImage = false;
  final bool _isUploadingResponseImage = false;
  bool _isLoading = false;
  bool _isSubmittingComment = false;
  bool _isSubmittingResponse = false;
  String? _errorMessage;

  // Getters
  List<Comment> get comments => _comments;
  Map<String, List<Comment>> get responses => _responses;
  Map<String, bool> get showAllResponsesMap => _showAllResponsesMap;
  User? get currentUser => _currentUser;
  bool get hasMoreComments => _hasMoreComments;
  File? get selectedImage => _selectedImage;
  File? get selectedResponseImage => _selectedResponseImage;
  String? get existingImageUrl => _existingImageUrl;
  bool get isUploadingImage => _isUploadingImage;
  bool get isUploadingResponseImage => _isUploadingResponseImage;
  bool get isLoading => _isLoading;
  bool get isSubmittingComment => _isSubmittingComment;
  bool get isSubmittingResponse => _isSubmittingResponse;
  String? get errorMessage => _errorMessage;

  Future<void> loadComments(
      {bool reset = false, int currentPage = 1, int pageLimit = 10}) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _commentRepository.getComments(
        planId,
        page: currentPage,
        limit: pageLimit,
      );

      switch (result) {
        case Ok<List<Comment>>():
          final commentsData = result.value;
          if (commentsData.length < pageLimit) {
            _hasMoreComments = false;
          }

          if (reset) {
            _comments = commentsData;
          } else {
            _comments.addAll(commentsData);
          }

          onCommentCountChanged?.call(_comments.length);

          // Load responses for comments that have them
          for (final comment in commentsData) {
            if (comment.id != null && comment.responses.isNotEmpty) {
              loadResponses(comment.id!);
            }
          }

          notifyListeners();
        case Error<List<Comment>>():
          _setError(
              'Erreur lors du chargement des commentaires : ${result.error.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadResponses(String commentId) async {
    try {
      if (_responses.containsKey(commentId)) return;

      final comment = _comments.firstWhere((c) => c.id == commentId);
      if (comment.responses.isEmpty) {
        _responses[commentId] = [];
        notifyListeners();
        return;
      }

      List<Comment> commentResponses = [];
      for (String responseId in comment.responses) {
        final result = await _commentRepository.getCommentById(responseId);
        switch (result) {
          case Ok<Comment>():
            commentResponses.add(result.value);
          case Error<Comment>():
            print(
                'Erreur lors du chargement de la réponse $responseId : ${result.error}');
        }
      }

      _responses[commentId] = commentResponses;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des réponses pour $commentId : $e');
    }
  }

  Future<Comment?> saveComment(String content) async {
    if (_isSubmittingComment) return null;

    bool hasText = content.trim().isNotEmpty;
    bool hasImage = _selectedImage != null || _existingImageUrl != null;

    if (!hasText && !hasImage) {
      _setError("Veuillez ajouter un texte ou une image");
      return null;
    }

    _setSubmittingComment(true);
    _clearError();

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final uploadResult =
            await _commentRepository.uploadImage(_selectedImage!);
        switch (uploadResult) {
          case Ok<String>():
            imageUrl = uploadResult.value;
          case Error<String>():
            throw Exception('Erreur lors de l\'upload: ${uploadResult.error}');
        }
      } else if (_existingImageUrl != null) {
        imageUrl = _existingImageUrl;
      }

      print('currentUser: $_currentUser');

      final newComment = Comment(
        content: content.trim(),
        planId: planId,
        imageUrl: imageUrl,
        user: _currentUser,
      );

      final result = await _commentRepository.createComment(planId, newComment);

      switch (result) {
        case Ok<Comment>():
          final createdComment = result.value;
          _comments.insert(0, createdComment);
          onCommentCountChanged?.call(_comments.length);
          Fluttertoast.showToast(msg: 'Commentaire ajouté avec succès');
          notifyListeners();
          return createdComment;
        case Error<Comment>():
          _setError("Erreur: ${result.error.toString()}");
          return null;
      }
    } finally {
      _setSubmittingComment(false);
    }
  }

  Future<Comment?> editComment(String commentId, String content,
      {File? newImage}) async {
    Comment? commentToEdit;
    bool isResponse = false;
    String? parentCommentId;

    try {
      commentToEdit =
          _comments.firstWhere((comment) => comment.id == commentId);
    } catch (e) {
      for (final parentId in _responses.keys) {
        try {
          commentToEdit = _responses[parentId]!
              .firstWhere((response) => response.id == commentId);
          isResponse = true;
          parentCommentId = parentId;
          break;
        } catch (e) {
          continue;
        }
      }
    }

    if (commentToEdit == null) return null;

    String? finalImageUrl;
    if (newImage != null) {
      final uploadResult = await _commentRepository.uploadImage(newImage);
      switch (uploadResult) {
        case Ok<String>():
          finalImageUrl = uploadResult.value;
        case Error<String>():
          throw Exception('Erreur lors de l\'upload: ${uploadResult.error}');
      }
    } else if (_existingImageUrl != null) {
      finalImageUrl = _existingImageUrl;
    }

    final updatedComment = Comment(
      id: commentId,
      content: content.trim(),
      user: commentToEdit.user,
      planId: planId,
      createdAt: commentToEdit.createdAt,
      likes: commentToEdit.likes,
      responses: commentToEdit.responses,
      parentId: commentToEdit.parentId,
      imageUrl: finalImageUrl,
    );

    final result =
        await _commentRepository.editComment(commentId, updatedComment);

    switch (result) {
      case Ok<void>():
        if (isResponse && parentCommentId != null) {
          final index =
              _responses[parentCommentId]!.indexWhere((r) => r.id == commentId);
          if (index != -1) {
            _responses[parentCommentId]![index] = updatedComment;
          }
        } else {
          final index = _comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _comments[index] = updatedComment;
          }
        }

        Fluttertoast.showToast(msg: 'Commentaire modifié avec succès');
        notifyListeners();
        return updatedComment;
      case Error<void>():
        _setError("Erreur: ${result.error.toString()}");
        return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    final result = await _commentRepository.deleteComment(commentId);

    switch (result) {
      case Ok<void>():
        final index =
            _comments.indexWhere((comment) => comment.id == commentId);
        if (index != -1) {
          _comments.removeAt(index);

          if (_responses.containsKey(commentId)) {
            _responses.remove(commentId);
          }

          onCommentCountChanged?.call(_comments.length);
        }

        Fluttertoast.showToast(
            msg: 'Commentaire et ses réponses supprimés avec succès');
        notifyListeners();
        return true;
      case Error<void>():
        _setError('Erreur lors de la suppression : ${result.error.toString()}');
        return false;
    }
  }

  Future<Comment?> saveResponse(String commentId, String content) async {
    if (_isSubmittingResponse) return null;

    bool hasText = content.trim().isNotEmpty;
    bool hasImage = _selectedResponseImage != null || _existingImageUrl != null;

    if (!hasText && !hasImage) {
      _setError("Veuillez ajouter un texte ou une image");
      return null;
    }

    _setSubmittingResponse(true);
    _clearError();

    try {
      String? imageUrl;
      if (_selectedResponseImage != null) {
        final uploadResult =
            await _commentRepository.uploadImage(_selectedResponseImage!);
        switch (uploadResult) {
          case Ok<String>():
            imageUrl = uploadResult.value;
          case Error<String>():
            throw Exception('Erreur lors de l\'upload: ${uploadResult.error}');
        }
      } else if (_existingImageUrl != null) {
        imageUrl = _existingImageUrl;
      }

      final response = Comment(
        content: content.trim(),
        planId: planId,
        parentId: commentId,
        imageUrl: imageUrl,
        user: _currentUser,
      );

      final createResult =
          await _commentRepository.respondToComment(commentId, response);

      switch (createResult) {
        case Ok<Comment>():
          final createdResponse = createResult.value;

          // Add response to the main comment
          if (_responses.containsKey(commentId)) {
            _responses[commentId]!.insert(0, createdResponse);
          } else {
            _responses[commentId] = [createdResponse];
          }

          // Update the main comment's responses list
          final mainCommentIndex =
              _comments.indexWhere((c) => c.id == commentId);
          if (mainCommentIndex != -1) {
            _comments[mainCommentIndex].responses.add(createdResponse.id!);
          }

          Fluttertoast.showToast(msg: 'Réponse ajoutée avec succès');
          notifyListeners();
          return createdResponse;
        case Error<Comment>():
          _setError("Erreur: ${createResult.error.toString()}");
          return null;
      }
    } finally {
      _setSubmittingResponse(false);
    }
  }

  Future<bool> deleteResponse(String commentId, String responseId) async {
    final result =
        await _commentRepository.deleteResponse(commentId, responseId);

    switch (result) {
      case Ok<void>():
        // Remove response from the main comment's responses
        if (_responses.containsKey(commentId)) {
          _responses[commentId] =
              _responses[commentId]!.where((r) => r.id != responseId).toList();
          if (_responses[commentId]!.isEmpty) {
            _responses.remove(commentId);
          }
        }

        // Update the main comment's responses list
        final mainCommentIndex = _comments.indexWhere((c) => c.id == commentId);
        if (mainCommentIndex != -1) {
          final updatedResponses =
              List<String>.from(_comments[mainCommentIndex].responses);
          updatedResponses.removeWhere((id) => id == responseId);
          _comments[mainCommentIndex] =
              _comments[mainCommentIndex].copyWith(responses: updatedResponses);
        }

        Fluttertoast.showToast(msg: 'Réponse supprimée avec succès');
        notifyListeners();
        return true;
      case Error<void>():
        _setError('Erreur lors de la suppression : ${result.error.toString()}');
        return false;
    }
  }

  Future<bool> toggleLike(Comment comment, bool isLiked) async {
    final result = isLiked
        ? await _commentRepository.unlikeComment(comment.id!)
        : await _commentRepository.likeComment(comment.id!);

    switch (result) {
      case Ok<void>():
        // Update the likes list
        final currentLikes = List<String>.from(comment.likes ?? []);
        if (isLiked) {
          currentLikes.remove(_currentUser?.id ?? '');
        } else {
          currentLikes.add(_currentUser?.id ?? '');
        }

        // Create updated comment with new likes
        final updatedComment = comment.copyWith(likes: currentLikes);

        // Update the comment in the main comments list
        final mainCommentIndex =
            _comments.indexWhere((c) => c.id == comment.id);
        if (mainCommentIndex != -1) {
          _comments[mainCommentIndex] = updatedComment;
        }

        // Update the comment in responses if it's a response
        for (final parentId in _responses.keys) {
          final responseIndex =
              _responses[parentId]!.indexWhere((r) => r.id == comment.id);
          if (responseIndex != -1) {
            _responses[parentId]![responseIndex] = updatedComment;
            break;
          }
        }

        notifyListeners();
        return true;
      case Error<void>():
        _setError('Erreur lors du like/unlike: ${result.error.toString()}');
        return false;
    }
  }

  // Image management methods
  void setSelectedImage(File imageFile) {
    _selectedImage = imageFile;
    notifyListeners();
  }

  void setSelectedResponseImage(File imageFile) {
    _selectedResponseImage = imageFile;
    notifyListeners();
  }

  void removeImage() {
    _selectedImage = null;
    _existingImageUrl = null;
    notifyListeners();
  }

  void removeResponseImage() {
    _selectedResponseImage = null;
    _existingImageUrl = null;
    notifyListeners();
  }

  void clearExistingImageUrl() {
    _existingImageUrl = null;
    notifyListeners();
  }

  void setExistingImageUrl(String? url) {
    _existingImageUrl = url;
    notifyListeners();
  }

  // Utility methods
  String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

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
      final comment = _comments.firstWhere((c) => c.id == commentId);
      return CommentResult(comment, false, null);
    } catch (e) {
      for (var parentId in _responses.keys) {
        try {
          final response =
              _responses[parentId]!.firstWhere((r) => r.id == commentId);
          return CommentResult(response, true, parentId);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  Future<User> getUserProfile(String userId) async {
    // First check if it's the current user
    if (_currentUser?.id == userId) {
      return _currentUser!;
    }

    // Then try to get from repository
    final result = await _userRepository.getUserById(userId);
    switch (result) {
      case Ok<User>():
        return result.value;
      case Error<User>():
        // Return a fallback user instead of throwing
        return User(
          id: userId,
          username: 'Utilisateur inconnu',
          email: '',
          photoUrl: null,
          description: null,
          isPremium: false,
          followers: [],
          following: [],
        );
    }
  }

  void toggleShowAllResponses(String commentId) {
    _showAllResponsesMap[commentId] =
        !(_showAllResponsesMap[commentId] ?? false);
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmittingComment(bool submitting) {
    _isSubmittingComment = submitting;
    notifyListeners();
  }

  void _setSubmittingResponse(bool submitting) {
    _isSubmittingResponse = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Helper class for comment results
class CommentResult {
  final Comment comment;
  final bool isResponse;
  final String? parentCommentId;

  CommentResult(this.comment, this.isResponse, this.parentCommentId);
}
