import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';

/// Data source for user related data
abstract class UserRepository {
  /// Get current user
  Future<Result<User>> getUser();

  /// Get user profile by ID
  Future<Result<User>> getUserProfile(String userId);

  /// Get user followers
  Future<Result<List<User>>> getUserFollowers(String userId);

  /// Get users that this user is following
  Future<Result<List<User>>> getUserFollowing(String userId);

  /// Follow a user
  Future<Result<void>> followUser(String userId);

  /// Unfollow a user
  Future<Result<void>> unfollowUser(String userId);

  /// Check if current user is following the specified user
  Future<Result<bool>> isFollowing(String userId);
}
