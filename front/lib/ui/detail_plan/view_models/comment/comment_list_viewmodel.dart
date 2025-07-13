import 'package:flutter/material.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../data/repositories/comment/comment_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../domain/models/comment/comment.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/result.dart';

/// -------------------------
/// STATE
/// -------------------------
class CommentListState {
  final List<Comment> comments;
  final Map<String, List<Comment>> responses;
  final Map<String, bool> showAllResponsesMap;
  final bool isLoading;
  final bool hasMoreComments;
  final String? respondingToCommentId;
  final String? errorMessage;

  const CommentListState({
    this.comments = const [],
    this.responses = const {},
    this.showAllResponsesMap = const {},
    this.isLoading = false,
    this.hasMoreComments = true,
    this.respondingToCommentId,
    this.errorMessage,
  });

  CommentListState copyWith({
    List<Comment>? comments,
    Map<String, List<Comment>>? responses,
    Map<String, bool>? showAllResponsesMap,
    bool? isLoading,
    bool? hasMoreComments,
    String? respondingToCommentId,
    String? errorMessage,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      responses: responses ?? this.responses,
      showAllResponsesMap: showAllResponsesMap ?? this.showAllResponsesMap,
      isLoading: isLoading ?? this.isLoading,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      respondingToCommentId:
          respondingToCommentId ?? this.respondingToCommentId,
      errorMessage: errorMessage,
    );
  }
}

/// -------------------------
/// VIEWMODEL
/// -------------------------
class CommentListViewModel {
  final AuthRepository _authRepository;
  final CommentRepository _commentRepository;
  final String planId;

  final ValueNotifier<CommentListState> state =
      ValueNotifier(const CommentListState());

  User? get currentUser => _authRepository.currentUser;

  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoadingMore = false;

  CommentListViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CommentRepository commentRepository,
    required this.planId,
  })  : _authRepository = authRepository,
        _commentRepository = commentRepository;

  Future<void> loadComments({
    bool reset = false,
  }) async {
    if (state.value.isLoading) return;

    if (reset) {
      _currentPage = 1;
      state.value = state.value.copyWith(comments: []);
    }

    state.value = state.value.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _commentRepository.getComments(planId,
          page: _currentPage, limit: _limit);

      if (result is Ok<List<Comment>>) {
        final newComments =
            reset ? result.value : [...state.value.comments, ...result.value];
        final hasMore = result.value.length >= _limit;

        state.value = state.value.copyWith(
          comments: newComments,
          hasMoreComments: hasMore,
        );
      } else if (result is Error<List<Comment>>) {
        state.value =
            state.value.copyWith(errorMessage: result.error.toString());
      }
    } finally {
      state.value = state.value.copyWith(isLoading: false);
    }
  }

  Future<void> loadMoreComments() async {
    if (_isLoadingMore || !state.value.hasMoreComments) return;
    _isLoadingMore = true;
    _currentPage++;

    try {
      final result = await _commentRepository.getComments(planId,
          page: _currentPage, limit: _limit);

      if (result is Ok<List<Comment>>) {
        final newComments = [...state.value.comments, ...result.value];
        final hasMore = result.value.length >= _limit;

        state.value = state.value.copyWith(
          comments: newComments,
          hasMoreComments: hasMore,
        );
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> loadResponses(String commentId) async {
    final responsesList = await _fetchResponses(commentId);
    final updatedResponses =
        Map<String, List<Comment>>.from(state.value.responses);
    updatedResponses[commentId] = responsesList;
    state.value = state.value.copyWith(responses: updatedResponses);
  }

  Future<List<Comment>> _fetchResponses(String commentId) async {
    final parentComment = state.value.comments.where((c) => c.id == commentId);
    if (parentComment.isEmpty) return [];

    final comment = parentComment.first;

    final responses = <Comment>[];
    for (final responseId in comment.responses) {
      final result = await _commentRepository.getCommentById(responseId);
      if (result is Ok<Comment>) {
        responses.add(result.value);
      }
    }
    return responses;
  }

  void addResponse(String commentId, Comment response) {
    final updatedResponses =
        Map<String, List<Comment>>.from(state.value.responses);
    updatedResponses.putIfAbsent(commentId, () => []);
    updatedResponses[commentId]!.insert(0, response);

    // 👉 Cette ligne manquait pour mettre à jour la liste des IDs de réponse du parent
    final updatedComments = [...state.value.comments];
    final idx = updatedComments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      final comment = updatedComments[idx];
      final updatedComment = comment.copyWith(
        responses: [...comment.responses, response.id!],
      );
      updatedComments[idx] = updatedComment;
    }

    final updatedShowAllMap =
        Map<String, bool>.from(state.value.showAllResponsesMap);
    updatedShowAllMap[commentId] = true;

    state.value = state.value.copyWith(
      comments: updatedComments,
      responses: updatedResponses,
      showAllResponsesMap: updatedShowAllMap,
    );
  }

  Future<void> deleteComment(String commentId) async {
    final result = await _commentRepository.deleteComment(commentId);
    if (result is Ok<void>) {
      final updatedComments =
          state.value.comments.where((c) => c.id != commentId).toList();
      final updatedResponses =
          Map<String, List<Comment>>.from(state.value.responses)
            ..remove(commentId);
      final updatedShowMap =
          Map<String, bool>.from(state.value.showAllResponsesMap)
            ..remove(commentId);

      state.value = state.value.copyWith(
        comments: updatedComments,
        responses: updatedResponses,
        showAllResponsesMap: updatedShowMap,
      );
    }
  }

  Future<void> deleteResponse(String commentId, String responseId) async {
    final result =
        await _commentRepository.deleteResponse(commentId, responseId);
    if (result is Ok<void>) {
      final updatedResponses =
          Map<String, List<Comment>>.from(state.value.responses);
      updatedResponses[commentId]?.removeWhere((r) => r.id == responseId);

      state.value = state.value.copyWith(responses: updatedResponses);
    }
  }

  Future<void> toggleLike(Comment comment) async {
    final isLiked = comment.likes?.contains(currentUser?.id) ?? false;
    final result = isLiked
        ? await _commentRepository.unlikeComment(comment.id!)
        : await _commentRepository.likeComment(comment.id!);

    if (result is Ok<void>) {
      final updatedLikes = List<String>.from(comment.likes ?? []);
      if (isLiked) {
        updatedLikes.remove(currentUser?.id);
      } else {
        updatedLikes.add(currentUser?.id ?? '');
      }

      final updatedComment = comment.copyWith(likes: updatedLikes);
      _updateCommentInState(updatedComment);
    }
  }

  void toggleShowAllResponses(String commentId) {
    final updatedMap = Map<String, bool>.from(state.value.showAllResponsesMap);
    updatedMap[commentId] = !(updatedMap[commentId] ?? false);
    state.value = state.value.copyWith(showAllResponsesMap: updatedMap);
  }

  void startRespondingTo(String commentId) {
    state.value = state.value.copyWith(respondingToCommentId: commentId);
  }

  void cancelResponding() {
    state.value = state.value.copyWith(respondingToCommentId: null);
  }

  void _updateCommentInState(Comment updatedComment) {
    final updatedComments = [...state.value.comments];
    final idx = updatedComments.indexWhere((c) => c.id == updatedComment.id);

    if (idx != -1) {
      updatedComments[idx] = updatedComment;
    } else {
      final updatedResponses =
          Map<String, List<Comment>>.from(state.value.responses);
      for (final entry in updatedResponses.entries) {
        final rIdx = entry.value.indexWhere((r) => r.id == updatedComment.id);
        if (rIdx != -1) {
          updatedResponses[entry.key]![rIdx] = updatedComment;
          state.value = state.value.copyWith(responses: updatedResponses);
          return;
        }
      }
    }

    state.value = state.value.copyWith(comments: updatedComments);
  }
}
