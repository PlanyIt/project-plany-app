import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/fakes/services/fake_imgur_service.dart';
import '../../../../testing/models/user.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('UserRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late FakeImgurService imgurService;
    late UserRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      imgurService = FakeImgurService();
      repository = UserRepositoryRemote(
        apiClient: apiClient,
        imgurService: imgurService,
      );
    });

    test('get user by id returns success', () async {
      final result = await repository.getUserById('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.username, 'USERNAME');
    });

    test('follow user returns success', () async {
      final result = await repository.followUser('user1');
      expect(result, isA<Ok>());
    });

    test('unfollow user returns success', () async {
      final result = await repository.unfollowUser('user1');
      expect(result, isA<Ok>());
    });

    test('is following returns success', () async {
      final result = await repository.isFollowing('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value, isTrue);
    });

    test('get user stats returns success', () async {
      final result = await repository.getUserStats('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.plansCount, greaterThan(0));
    });

    test('get followers returns success', () async {
      final result = await repository.getFollowers('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.length, greaterThan(0));
    });

    test('get following returns success', () async {
      final result = await repository.getFollowing('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.length, greaterThan(0));
    });

    test('update email returns success', () async {
      final result =
          await repository.updateEmail('new@email.com', 'password', 'user1');
      expect(result, isA<Ok>());
    });

    test('upload image returns fake url', () async {
      final file = File('test.jpg');
      final result = await repository.uploadImage(file);
      expect(result, isA<Ok>());
      expect(result.asOk.value, startsWith('https://fake-storage.com/'));
    });

    test('update user profile returns success', () async {
      final result = await repository.updateUserProfile(kUser);
      expect(result, isA<Ok>());
      expect(result.asOk.value.username, kUser.username);
    });
  });
}
