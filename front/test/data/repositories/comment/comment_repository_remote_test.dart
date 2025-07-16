import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/comment/comment_repository_remote.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/fakes/services/fake_imgur_service.dart';
import '../../../../testing/models/comment.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('CommentRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late FakeImgurService imgurService;
    late CommentRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      imgurService = FakeImgurService();
      repository = CommentRepositoryRemote(
        apiClient: apiClient,
        imgurService: imgurService,
      );
    });

    test('get comments returns success', () async {
      final result = await repository.getComments('plan1');
      expect(result, isA<Ok>());
      final list = result.asOk.value;
      expect(list.length, greaterThan(0));
    });

    test('get comment responses returns success', () async {
      final result = await repository.getCommentResponses('comment1');
      expect(result, isA<Ok>());
      final list = result.asOk.value;
      expect(list.length, greaterThan(0));
    });

    test('create comment with valid data', () async {
      final comment = kComment.copyWith(content: 'This is a comment');
      final result = await repository.createComment('plan1', comment);
      expect(result, isA<Ok>());
    });

    test('create comment fails with empty content', () async {
      final comment = kComment.copyWith(content: '');
      final result = await repository.createComment('plan1', comment);
      expect(result, isA<Error>());
    });

    test('create comment fails with empty planId', () async {
      final comment = kComment.copyWith(content: 'Valid content');
      final result = await repository.createComment('', comment);
      expect(result, isA<Error>());
      expect(result.asError.error.toString(), contains('Plan ID is required'));
    });

    test('create comment fails with API exception', () async {
      final original = apiClient.createCommentFn;
      apiClient.createCommentFn = (String planId, dynamic comment) async {
        throw Exception('500 Internal Server Error');
      };
      final result = await repository.createComment('plan1', kComment);
      expect(result, isA<Error>());
      expect(result.asError.error.toString(), contains('Server error'));
      apiClient.createCommentFn = original;
    });

    test('edit comment returns success', () async {
      final result = await repository.editComment('commentId', kComment);
      expect(result, isA<Ok>());
    });

    test('edit comment fails with API exception', () async {
      final original = apiClient.editCommentFn;
      apiClient.editCommentFn = (String commentId, dynamic comment) async {
        throw Exception('403 Forbidden');
      };
      final result = await repository.editComment('id', kComment);
      expect(result, isA<Error>());
      expect(
          result.asError.error.toString(), contains('Failed to edit comment'));
      apiClient.editCommentFn = original;
    });

    test('delete comment returns success', () async {
      final result = await repository.deleteComment('commentId');
      expect(result, isA<Ok>());
    });

    test('delete comment fails with API exception', () async {
      final original = apiClient.deleteCommentFn;
      apiClient.deleteCommentFn = (String commentId) async {
        throw Exception('401 Unauthorized');
      };
      final result = await repository.deleteComment('id');
      expect(result, isA<Error>());
      expect(result.asError.error.toString(),
          contains('Failed to delete comment'));
      apiClient.deleteCommentFn = original;
    });

    test('get comment by id returns success', () async {
      final result = await repository.getCommentById('commentId');
      expect(result, isA<Ok>());
    });

    test('get comment by id fails with API exception', () async {
      final original = apiClient.getCommentByIdFn;
      apiClient.getCommentByIdFn = (String commentId) async {
        throw Exception('404 Not Found');
      };
      final result = await repository.getCommentById('id');
      expect(result, isA<Error>());
      expect(
          result.asError.error.toString(), contains('Failed to get comment'));
      apiClient.getCommentByIdFn = original;
    });

    test('like comment returns success', () async {
      final result = await repository.likeComment('commentId');
      expect(result, isA<Ok>());
    });

    test('unlike comment returns success', () async {
      final result = await repository.unlikeComment('commentId');
      expect(result, isA<Ok>());
    });

    test('respond to comment returns success', () async {
      final result = await repository.respondToComment('commentId', kComment);
      expect(result, isA<Ok>());
    });

    test('delete response returns success', () async {
      final result = await repository.deleteResponse('commentId', 'responseId');
      expect(result, isA<Ok>());
    });

    test('add response to comment returns success', () async {
      final result =
          await repository.addResponseToComment('commentId', 'responseId');
      expect(result, isA<Ok>());
    });

    test('upload image returns fake url', () async {
      final file = File('test.jpg');
      final result = await repository.uploadImage(file);
      expect(result, isA<Ok>());
      expect(result.asOk.value, startsWith('https://fake-storage.com/'));
    });
  });
}
