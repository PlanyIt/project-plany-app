import 'package:flutter/foundation.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({
    required ApiClient apiClient,
    required AuthStorageService authStorageService,
  })  : _apiClient = apiClient,
        _authStorageService = authStorageService;

  final ApiClient _apiClient;
  final AuthStorageService _authStorageService;

  User? _cachedUser;

  @override
  Future<Result<User>> getCurrentUser() async {
    if (_cachedUser != null) {
      if (kDebugMode) print('✅ Returning cached user');
      return Result.ok(_cachedUser!);
    }

    final userIdResult = await _authStorageService.fetchUserId();
    if (kDebugMode) print('🧩 SharedPreferences returned: $userIdResult');

    if (userIdResult is Error<String?>) {
      return Result.error(userIdResult.error);
    }

    final userId = (userIdResult as Ok<String?>).value;
    if (userId == null) {
      return Result.error(Exception('User ID not found in SharedPreferences'));
    }

    if (kDebugMode) print('🌐 Fetching user with ID: $userId');
    final result = await _apiClient.getUser(userId);

    if (kDebugMode) print('📦 API response: $result');

    if (result is Ok<User>) {
      _cachedUser = result.value;
      return Result.ok(_cachedUser!);
    } else {
      return Result.error((result as Error<User>).error);
    }
  }

  void clearUserCache() {
    if (kDebugMode) print('🧹 Clearing user cache');
    _cachedUser = null;
  }

  @override
  Future<Result<User>> patchCurrentUser(Map<String, dynamic> data) {
    if (_cachedUser == null) {
      return Future.error(Exception('No user cached'));
    }

    final userId = _cachedUser!.id;

    if (kDebugMode) print('🌐 Patching user with ID: $userId');

    return _apiClient.patchUser(userId, data).then((result) {
      if (result is Ok<User>) {
        _cachedUser = result.value;
        return Result.ok(_cachedUser!);
      } else {
        return Result.error((result as Error<User>).error);
      }
    });
  }

  @override
  Future<Result<User>> getUserProfile(String userId) {
    if (kDebugMode) print('🌐 Fetching user profile with ID: $userId');

    return _apiClient.getUser(userId).then((result) {
      if (result is Ok<User>) {
        return Result.ok(result.value);
      } else {
        return Result.error((result as Error<User>).error);
      }
    });
  }

  @override
  Future<Result<List<User>>> getUsers() {
    if (kDebugMode) print('🌐 Fetching all users');
    return _apiClient.getUsers();
  }

  @override
  Future<Result<User>> createUser(Map<String, dynamic> body) {
    if (kDebugMode) print('🌐 Creating user with data: $body');
    return _apiClient.createUser(body);
  }

  @override
  Future<Result<void>> deleteUser(String userId) {
    if (kDebugMode) print('🌐 Deleting user with ID: $userId');
    return _apiClient.deleteUser(userId);
  }

  @override
  Future<Result<User>> getUserByUsername(String username) {
    if (kDebugMode) print('🌐 Fetching user by username: $username');
    return _apiClient.getUserByUsername(username);
  }

  @override
  Future<Result<User>> getUserByEmail(String email) {
    if (kDebugMode) print('🌐 Fetching user by email: $email');
    return _apiClient.getUserByEmail(email);
  }

  @override
  Future<Result<User>> updateUserEmail(String userId, String email) {
    if (kDebugMode) print('🌐 Updating email for user: $userId');
    return _apiClient.updateUserEmail(userId, email).then((result) {
      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }
      return result;
    });
  }

  @override
  Future<Result<User>> updateUserPhoto(String userId, String photoUrl) {
    if (kDebugMode) print('🌐 Updating photo for user: $userId');
    return _apiClient.updateUserPhoto(userId, photoUrl).then((result) {
      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }
      return result;
    });
  }

  @override
  Future<Result<User>> deleteUserPhoto(String userId) {
    if (kDebugMode) print('🌐 Deleting photo for user: $userId');
    return _apiClient.deleteUserPhoto(userId).then((result) {
      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }
      return result;
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserStats(String userId) {
    if (kDebugMode) print('🌐 Fetching stats for user: $userId');
    return _apiClient.getUserStats(userId);
  }

  @override
  Future<Result<List<Plan>>> getUserPlans(String userId) {
    if (kDebugMode) print('🌐 Fetching plans for user: $userId');
    return _apiClient.getUserPlans(userId);
  }

  @override
  Future<Result<List<Plan>>> getUserFavorites(String userId) {
    if (kDebugMode) print('🌐 Fetching favorites for user: $userId');
    return _apiClient.getUserFavorites(userId);
  }

  @override
  Future<Result<User>> updateUserPremiumStatus(String userId, bool isPremium) {
    if (kDebugMode)
      print('🌐 Updating premium status for user: $userId to $isPremium');
    return _apiClient.updateUserPremiumStatus(userId, isPremium).then((result) {
      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }
      return result;
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> followUser(String targetUserId) {
    if (kDebugMode) print('🌐 Following user: $targetUserId');
    return _apiClient.followUser(targetUserId);
  }

  @override
  Future<Result<Map<String, dynamic>>> unfollowUser(String targetUserId) {
    if (kDebugMode) print('🌐 Unfollowing user: $targetUserId');
    return _apiClient.unfollowUser(targetUserId);
  }

  @override
  Future<Result<List<User>>> getUserFollowers(String userId) {
    if (kDebugMode) print('🌐 Fetching followers for user: $userId');
    return _apiClient.getUserFollowers(userId);
  }

  @override
  Future<Result<List<User>>> getUserFollowing(String userId) {
    if (kDebugMode) print('🌐 Fetching following for user: $userId');
    return _apiClient.getUserFollowing(userId);
  }

  @override
  Future<Result<Map<String, dynamic>>> checkFollowing(
      String followerId, String targetId) {
    if (kDebugMode) print('🌐 Checking if user $followerId follows $targetId');
    return _apiClient.checkFollowing(followerId, targetId);
  }
}
