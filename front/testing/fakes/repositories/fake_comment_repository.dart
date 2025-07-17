import 'dart:io';

import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/utils/result.dart';

class FakeCommentRepository extends CommentRepository {
  final List<Comment> _comments = [];
  int _idCounter = 0;

  @override
  Future<Result<List<Comment>>> getComments(String planId,
      {int page = 1, int limit = 10}) async {
    final filtered = _comments.where((c) => c.planId == planId).toList();
    return Result.ok(filtered);
  }

  @override
  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    final responses = _comments.where((c) => c.parentId == commentId).toList();
    return Result.ok(responses);
  }

  @override
  Future<Result<Comment>> createComment(String planId, Comment comment) async {
    final newComment = comment.copyWith(
      id: 'comment_${_idCounter++}',
      planId: planId,
    );
    _comments.add(newComment);
    return Result.ok(newComment);
  }

  @override
  Future<Result<void>> editComment(String commentId, Comment comment) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      _comments[index] = comment.copyWith(id: commentId);
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    _comments.removeWhere((c) => c.id == commentId);
    return const Result.ok(null);
  }

  @override
  Future<Result<Comment>> getCommentById(String commentId) async {
    final comment = _comments.firstWhere(
      (c) => c.id == commentId,
      orElse: () =>
          Comment(id: commentId, content: 'Unknown', planId: 'unknown'),
    );
    return Result.ok(comment);
  }

  @override
  Future<Result<void>> likeComment(String commentId) async {
    // Fake behavior, do nothing
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unlikeComment(String commentId) async {
    // Fake behavior, do nothing
    return const Result.ok(null);
  }

  @override
  Future<Result<Comment>> respondToComment(
      String commentId, Comment comment) async {
    final newResponse = comment.copyWith(
      id: 'response_${_idCounter++}',
      parentId: commentId,
    );
    _comments.add(newResponse);
    return Result.ok(newResponse);
  }

  @override
  Future<Result<void>> deleteResponse(
      String commentId, String responseId) async {
    _comments.removeWhere((c) => c.id == responseId && c.parentId == commentId);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> addResponseToComment(
      String commentId, String responseId) async {
    // Fake behavior, do nothing
    return const Result.ok(null);
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    // Simule un upload et retourne une URL factice
    return Result.ok(
        'https://fake-storage.com/images/${imageFile.path.split('/').last}');
  }
}
