import 'dart:io';

import '../../../domain/models/user/user.dart';
import '../../../domain/models/user/user_stats.dart';
import '../../../utils/result.dart';

/// Data source for user related data
abstract class UserRepository {
  /// Get the user by their ID
  Future<Result<User>> getUserById(String userId);

  /// Follow a user
  Future<Result<void>> followUser(String userId);

  /// Unfollow a user
  Future<Result<void>> unfollowUser(String userId);

  /// Check if current user is following another user
  Future<Result<bool>> isFollowing(String userId);

  /// Get User statistics
  Future<Result<UserStats>> getUserStats(String? userId);

  /// Get User's followers
  Future<Result<List<User>>> getFollowers(String userId);

  /// Get User's following
  Future<Result<List<User>>> getFollowing(String userId);

  /// Update email of the current user
  Future<Result<void>> updateEmail(
      String email, String password, String userId);

  /// Upload image for the user
  Future<Result<String>> uploadImage(File imageFile);

  /// Update the user profile
  Future<Result<User>> updateUserProfile(User user);
}
