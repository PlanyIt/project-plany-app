import 'dart:io';

import '../../../domain/models/user/user.dart';
import '../../../domain/models/user/user_stats.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/user/user_api_model.dart';
import '../../services/imgur_service.dart';
import 'user_repository.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final ImgurService _imgurService = ImgurService();

  @override
  Future<Result<User>> getUserById(String userId) {
    return _apiClient.getUserById(userId).then((result) {
      switch (result) {
        case Ok<UserApiModel>():
          final user = User(
            id: result.value.id,
            username: result.value.username,
            email: result.value.email,
            description: result.value.description,
            isPremium: result.value.isPremium,
            photoUrl: result.value.photoUrl,
            birthDate: result.value.birthDate,
            gender: result.value.gender,
            followers: result.value.followers,
            following: result.value.following,
          );
          return Result.ok(user);
        case Error<UserApiModel>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<void>> followUser(String userId) async {
    return _apiClient.followUser(userId);
  }

  @override
  Future<Result<void>> unfollowUser(String userId) async {
    print('Unfollowing user: $userId');
    return _apiClient.unfollowUser(userId);
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    return _apiClient.isFollowing(userId);
  }

  @override
  Future<Result<UserStats>> getUserStats(String? userId) {
    return _apiClient.getUserStats(userId ?? '').then((result) {
      switch (result) {
        case Ok<UserStats>():
          return Result.ok(result.value);
        case Error<UserStats>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<List<User>>> getFollowers(String userId) {
    return _apiClient.getFollowers(userId).then((result) {
      switch (result) {
        case Ok<List<User>>():
          return Result.ok(result.value);
        case Error<List<User>>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<List<User>>> getFollowing(String userId) {
    return _apiClient.getFollowing(userId).then((result) {
      switch (result) {
        case Ok<List<User>>():
          return Result.ok(result.value);
        case Error<List<User>>():
          return Result.error(result.error);
      }
    });
  }

  @override
  Future<Result<void>> updateEmail(
      String email, String password, String userId) {
    return _apiClient.updateEmail(email, password, userId).then((result) {
      switch (result) {
        case Ok<void>():
          return Result.ok(null);
        case Error<void>():
          return Result.error(result.error);
      }
    });
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

  @override
  Future<Result<User>> updateUserProfile(User user) {
    return _apiClient.updateUserProfile(user).then((result) {
      switch (result) {
        case Ok<UserApiModel>():
          final user = User(
            id: result.value.id,
            username: result.value.username,
            email: result.value.email,
            description: result.value.description,
            isPremium: result.value.isPremium,
            photoUrl: result.value.photoUrl,
            birthDate: result.value.birthDate,
            gender: result.value.gender,
            followers: result.value.followers,
            following: result.value.following,
          );

          return Result.ok(user);
        case Error<UserApiModel>():
          return Result.error(result.error);
      }
    });
  }
}
