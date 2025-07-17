import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';
import 'package:mocktail/mocktail.dart';

import '../../../testing/mocks.dart';
import '../../../testing/models/category.dart';
import '../../../testing/models/comment.dart';
import '../../../testing/models/plan.dart';
import '../../../testing/models/step.dart';
import '../../../testing/models/user.dart';
import '../../../testing/utils/result.dart';

void main() {
  group('ApiClient tests', () {
    late MockHttpClient mockHttpClient;
    late ApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(Uri());
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiClient = ApiClient(clientFactory: () => mockHttpClient);
    });

    test('should handle change password success', () async {
      mockHttpClient.mockPost('/api/auth/change-password', {}, 200);
      final result = await apiClient.changePassword('current', 'new');
      expect(result, isA<Ok>());
    });

    test('should handle invalid json in createPlan', () async {
      mockHttpClient.mockPost('/api/plans', ['unexpected'], 201);
      final result = await apiClient.createPlan(body: {});
      expect(result, isA<Error>());
    });

    test('should handle error on getUserById', () async {
      mockHttpClient.mockGetThrows('/api/users/user1', SocketException('fail'));
      final result = await apiClient.getUserById('user1');
      expect(result, isA<Error>());
    });

    test('should fail if createStep returns 400', () async {
      mockHttpClient.mockPost('/api/steps', {}, 400);
      final step = Step(title: 'x', description: '', order: 0, image: '');
      final result = await apiClient.createStep(step);
      expect(result, isA<Error>());
    });

    test('should not crash when authHeaderProvider returns null', () async {
      apiClient.authHeaderProvider = () => null;
      mockHttpClient.mockGet('/api/plans', [kPlan]);
      final result = await apiClient.getPlans();
      expect(result, isA<Ok>());
    });

    test('should handle change password failure', () async {
      mockHttpClient.mockPost('/api/auth/change-password', {}, 500);
      final result = await apiClient.changePassword('current', 'new');
      expect(result, isA<Error>());
    });

    test('should fail if deletePlan returns error', () async {
      mockHttpClient.mockDelete('/api/plans/plan1', {}, 500);
      final result = await apiClient.deletePlan('plan1');
      expect(result, isA<Error>());
    });

    test('should fail if updateEmail returns error', () async {
      mockHttpClient.mockPatch('/api/users/user1/email', {}, 500);
      final result = await apiClient.updateEmail('email', 'pass', 'user1');
      expect(result, isA<Error>());
    });

    test('should get plans', () async {
      mockHttpClient.mockGet('/api/plans', [kPlan]);
      final result = await apiClient.getPlans();
      expect(result.asOk.value, [kPlan]);
    });

    test('should get plan by id', () async {
      mockHttpClient.mockGet('/api/plans/plan1', kPlan);
      final result = await apiClient.getPlan('plan1');
      expect(result.asOk.value, kPlan);
    });

    test('should get categories', () async {
      mockHttpClient.mockGet('/api/categories', [kCategory]);
      final result = await apiClient.getCategories();
      expect(result.asOk.value, [kCategory]);
    });

    test('should get category by id', () async {
      mockHttpClient.mockGet('/api/categories/1', kCategory);
      final result = await apiClient.getCategory('1');
      expect(result.asOk.value, kCategory);
    });

    test('should get steps by plan id', () async {
      mockHttpClient.mockGet('/api/steps/plan/plan1', [stepApiModel]);
      final result = await apiClient.getStepsByPlan('plan1');
      expect(result.asOk.value.first.title, stepApiModel.title);
    });

    test('should create plan', () async {
      mockHttpClient.mockPost('/api/plans', kPlan);
      final result = await apiClient.createPlan(body: {});
      expect(result.asOk.value, kPlan);
    });

    test('should create step', () async {
      mockHttpClient.mockPost('/api/steps', stepApiModel);
      final step = Step(
        title: stepApiModel.title,
        description: stepApiModel.description,
        order: stepApiModel.order,
        image: stepApiModel.image,
      );
      final result = await apiClient.createStep(step);
      expect(result.asOk.value.title, step.title);
    });

    test('should delete plan', () async {
      mockHttpClient.mockDelete('/api/plans/plan1', {}, 200);
      final result = await apiClient.deletePlan('plan1');
      expect(result, isA<Ok>());
    });

    test('should create comment', () async {
      mockHttpClient.mockPost('/api/comments', {
        '_id': 'comment1',
        'content': 'My comment',
        'user': null,
        'planId': 'plan1',
      });
      final result = await apiClient.createComment('plan1', kComment);
      expect(result, isA<Ok>());
      expect(result.asOk.value.content, 'My comment');
    });

    test('should get comment by id', () async {
      mockHttpClient.mockGet('/api/comments/comment1', {
        '_id': 'comment1',
        'content': 'Test',
        'user': null,
        'planId': 'plan1',
      });
      final result = await apiClient.getCommentById('comment1');
      expect(result, isA<Ok>());
    });

    test('should respond to comment', () async {
      mockHttpClient.mockPost('/api/comments/comment1/response', {
        '_id': 'comment1',
        'content': 'response',
        'user': null,
        'planId': 'plan1',
      });
      final result = await apiClient.respondToComment('comment1', kComment);
      expect(result, isA<Ok>());
    });

    test('should unfollow user', () async {
      mockHttpClient.mockDelete('/api/users/user1/follow', {}, 200);
      final result = await apiClient.unfollowUser('user1');
      expect(result, isA<Ok>());
    });

    test('should delete comment', () async {
      mockHttpClient.mockDelete('/api/comments/comment1', {}, 200);
      final result = await apiClient.deleteComment('comment1');
      expect(result, isA<Ok>());
    });

    test('should get comments', () async {
      mockHttpClient.mockGet('/api/comments/plan/plan1?page=1&limit=10', {
        'comments': [kComment]
      });
      final result = await apiClient.getComments('plan1');
      expect(result.asOk.value, [kComment]);
    });

    test('should get comment responses', () async {
      mockHttpClient.mockGet('/api/comments/comment1/responses', [kComment]);
      final result = await apiClient.getCommentResponses('comment1');
      expect(result.asOk.value, [kComment]);
    });

    test('should get followers', () async {
      mockHttpClient.mockGet('/api/users/user1/followers', [kUser]);
      final result = await apiClient.getFollowers('user1');
      expect(result.asOk.value, [kUser]);
    });

    test('should get following', () async {
      mockHttpClient.mockGet('/api/users/user1/following', [kUser]);
      final result = await apiClient.getFollowing('user1');
      expect(result.asOk.value, [kUser]);
    });

    test('should get user by id', () async {
      mockHttpClient.mockGet('/api/users/user1', kUser);
      final result = await apiClient.getUserById('user1');
      expect(result.asOk.value, kUser);
    });

    test('should update email', () async {
      mockHttpClient.mockPatch('/api/users/user1/email', {}, 200);
      final result =
          await apiClient.updateEmail('test@email.com', 'pass', 'user1');
      expect(result, isA<Ok>());
    });

    test('should like comment', () async {
      mockHttpClient.mockPut('/api/comments/comment1/like', {});
      final result = await apiClient.likeComment('comment1');
      expect(result, isA<Ok>());
    });

    test('should unlike comment', () async {
      mockHttpClient.mockPut('/api/comments/comment1/unlike', {});
      final result = await apiClient.unlikeComment('comment1');
      expect(result, isA<Ok>());
    });

    test('should follow user', () async {
      mockHttpClient.mockPost('/api/users/user1/follow', {});
      final result = await apiClient.followUser('user1');
      expect(result, isA<Ok>());
    });

    test('should add plan to favorites', () async {
      mockHttpClient.mockPut('/api/plans/plan1/favorite', {});
      final result = await apiClient.addPlanToFavorites('plan1');
      expect(result, isA<Ok>());
    });

    test('should remove plan from favorites', () async {
      mockHttpClient.mockPut('/api/plans/plan1/unfavorite', {});
      final result = await apiClient.removePlanFromFavorites('plan1');
      expect(result, isA<Ok>());
    });

    test('should get favorites by user', () async {
      mockHttpClient.mockGet('/api/users/user1/favorites', [kPlan]);
      final result = await apiClient.getFavoritesByUser('user1');
      expect(result.asOk.value, [kPlan]);
    });

    test('should get plans by user', () async {
      mockHttpClient.mockGet('/api/plans/user/user1', [kPlan]);
      final result = await apiClient.getPlansByUser('user1');
      expect(result.asOk.value, [kPlan]);
    });

    test('should check if following', () async {
      mockHttpClient
          .mockGet('/api/users/me/following/user1', {'isFollowing': true});
      final result = await apiClient.isFollowing('user1');
      expect(result.asOk.value, isTrue);
    });

    test('should delete response', () async {
      mockHttpClient.mockDelete(
          '/api/comments/comment1/response/response1', {}, 200);
      final result = await apiClient.deleteResponse('comment1', 'response1');
      expect(result, isA<Ok>());
    });

    test('should add response to comment', () async {
      mockHttpClient.mockPut('/api/comments/comment1/responses', {});
      final result =
          await apiClient.addResponseToComment('comment1', 'response1');
      expect(result, isA<Ok>());
    });

    test('should edit comment', () async {
      mockHttpClient.mockPut('/api/comments/comment1', {});
      final result = await apiClient.editComment('comment1', kComment);
      expect(result, isA<Ok>());
    });

    test('should handle errors on getPlans', () async {
      mockHttpClient.mockGetThrows('/api/plans', Exception('fail'));
      final result = await apiClient.getPlans();
      expect(result, isA<Error>());
    });

    test('should update user profile', () async {
      mockHttpClient.mockPatch(
          '/api/users/user1/profile',
          {
            '_id': 'user1',
            'username': 'John',
            'email': 'john@example.com',
            'description': '',
            'isPremium': false,
            'photoUrl': null,
            'birthDate': null,
            'gender': null,
            'followers': [],
            'following': [],
            'followersCount': 0,
            'followingCount': 0,
            'plansCount': 0,
            'favoritesCount': 0,
          },
          200);

      final user = kUser.copyWith(id: 'user1');
      final result = await apiClient.updateUserProfile(user);
      expect(result, isA<Ok>());
    });

    test('should return false on isFollowing if response is invalid', () async {
      mockHttpClient.mockGet('/api/users/me/following/user1', {});
      final result = await apiClient.isFollowing('user1');
      expect(result.asOk.value, isFalse);
    });

    test('should fail to follow user on exception', () async {
      mockHttpClient.mockPostThrows(
          '/api/users/user1/follow', Exception('fail'));
      final result = await apiClient.followUser('user1');
      expect(result, isA<Error>());
    });

    test('should fail to unfollow user on exception', () async {
      mockHttpClient.mockDeleteThrows(
          '/api/users/user1/follow', Exception('fail'));
      final result = await apiClient.unfollowUser('user1');
      expect(result, isA<Error>());
    });

    test('should fail to like comment on error', () async {
      mockHttpClient.mockPut('/api/comments/comment1/like', {}, 500);
      final result = await apiClient.likeComment('comment1');
      expect(result, isA<Error>());
    });

    test('should fail to unlike comment on error', () async {
      mockHttpClient.mockPut('/api/comments/comment1/unlike', {}, 500);
      final result = await apiClient.unlikeComment('comment1');
      expect(result, isA<Error>());
    });

    test('should fail to edit comment on error', () async {
      mockHttpClient.mockPut('/api/comments/comment1', {}, 500);
      final result = await apiClient.editComment('comment1', kComment);
      expect(result, isA<Error>());
    });

    test('should fail to add response to comment on error', () async {
      mockHttpClient.mockPut('/api/comments/comment1/responses', {}, 500);
      final result =
          await apiClient.addResponseToComment('comment1', 'response1');
      expect(result, isA<Error>());
    });

    test('should fail to delete response on error', () async {
      mockHttpClient.mockDelete(
          '/api/comments/comment1/response/response1', {}, 500);
      final result = await apiClient.deleteResponse('comment1', 'response1');
      expect(result, isA<Error>());
    });

    test('should fail to get followers on exception', () async {
      mockHttpClient.mockGetThrows(
          '/api/users/user1/followers', Exception('fail'));
      final result = await apiClient.getFollowers('user1');
      expect(result, isA<Error>());
    });

    test('should fail to get following on exception', () async {
      mockHttpClient.mockGetThrows(
          '/api/users/user1/following', Exception('fail'));
      final result = await apiClient.getFollowing('user1');
      expect(result, isA<Error>());
    });

    test('should fail to get favorites by user on exception', () async {
      mockHttpClient.mockGetThrows(
          '/api/users/user1/favorites', Exception('fail'));
      final result = await apiClient.getFavoritesByUser('user1');
      expect(result, isA<Error>());
    });

    test('should fail to get plans by user on exception', () async {
      mockHttpClient.mockGetThrows('/api/plans/user/user1', Exception('fail'));
      final result = await apiClient.getPlansByUser('user1');
      expect(result, isA<Error>());
    });

    test('should fail to respond to comment if response missing _id', () async {
      mockHttpClient.mockPost('/api/comments/comment1/response', {});
      final result = await apiClient.respondToComment('comment1', kComment);
      expect(result, isA<Error>());
    });

    test('should fail to create comment if response missing _id', () async {
      mockHttpClient.mockPost('/api/comments', {});
      final result = await apiClient.createComment('plan1', kComment);
      expect(result, isA<Error>());
    });

    test('should fail to add plan to favorites on error', () async {
      mockHttpClient.mockPut('/api/plans/plan1/favorite', {}, 500);
      final result = await apiClient.addPlanToFavorites('plan1');
      expect(result, isA<Error>());
    });

    test('should fail to remove plan from favorites on error', () async {
      mockHttpClient.mockPut('/api/plans/plan1/unfavorite', {}, 500);
      final result = await apiClient.removePlanFromFavorites('plan1');
      expect(result, isA<Error>());
    });

    test('should get user stats', () async {
      mockHttpClient.mockGet('/api/users/user1/stats', {
        'plansCount': 3,
        'favoritesCount': 5,
        'followersCount': 10,
        'followingCount': 5,
      });
      final result = await apiClient.getUserStats('user1');
      expect(result, isA<Ok>());
    });

    test('should fail to get user stats on exception', () async {
      mockHttpClient.mockGetThrows('/api/users/user1/stats', Exception('fail'));
      final result = await apiClient.getUserStats('user1');
      expect(result, isA<Error>());
    });
  });
}
