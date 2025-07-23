import 'dart:io';

import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/domain/models/user/user_stats.dart';
import 'package:front/utils/result.dart';

class FakeUserRepository extends UserRepository {
  void clearCache() {
    _currentUser = null;
    _followers.clear();
    _following.clear();
    _isFollowing = false;
  }

  User? _currentUser = User(
    id: 'fake_id',
    username: 'fake_user',
    email: 'fake@user.com',
  );

  final List<User> _followers = [
    User(id: 'follower1', username: 'Follower 1', email: 'f1@email.com'),
    User(id: 'follower2', username: 'Follower 2', email: 'f2@email.com'),
  ];

  final List<User> _following = [
    User(id: 'following1', username: 'Following 1', email: 'fo1@email.com'),
    User(id: 'following2', username: 'Following 2', email: 'fo2@email.com'),
  ];

  bool _isFollowing = true;

  @override
  Future<Result<User>> getUserById(String userId) async {
    return Result.ok(
        User(id: userId, username: 'User$userId', email: '$userId@email.com'));
  }

  @override
  Future<Result<void>> followUser(String userId) async {
    _isFollowing = true;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unfollowUser(String userId) async {
    _isFollowing = false;
    return const Result.ok(null);
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    return Result.ok(_isFollowing);
  }

  @override
  Future<Result<UserStats>> getUserStats(String? userId) async {
    return Result.ok(UserStats(
      plansCount: 3,
      followersCount: _followers.length,
      followingCount: _following.length,
      favoritesCount: 2,
    ));
  }

  @override
  Future<Result<List<User>>> getFollowers(String userId) async {
    return Result.ok(_followers);
  }

  @override
  Future<Result<List<User>>> getFollowing(String userId) async {
    return Result.ok(_following);
  }

  @override
  Future<Result<void>> updateEmail(
      String email, String password, String userId) async {
    _currentUser = _currentUser?.copyWith(email: email);
    return const Result.ok(null);
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    return Result.ok(
        'https://fake-storage.com/images/${imageFile.path.split('/').last}');
  }

  @override
  Future<Result<User>> updateUserProfile(User user) async {
    _currentUser = user;
    return Result.ok(_currentUser!);
  }
}
