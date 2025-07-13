import '../../../domain/models/user/user.dart';
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
}
