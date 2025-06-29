import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';

/// Data source for user related data
abstract class UserRepository {
  /// Get current user
  Future<Result<User>> getCurrentUser();

  /// Patch current user with the given data
  Future<Result<User>> patchCurrentUser(Map<String, dynamic> data);

  /// Get user profile by ID
  Future<Result<User>> getUserProfile(String userId);

  /// Get all users
  Future<Result<List<User>>> getUsers();

  /// Create a new user
  Future<Result<User>> createUser(Map<String, dynamic> body);

  /// Delete user by ID
  Future<Result<void>> deleteUser(String userId);

  /// Get user by username
  Future<Result<User>> getUserByUsername(String username);

  /// Get user by email
  Future<Result<User>> getUserByEmail(String email);

  /// Update user email
  Future<Result<User>> updateUserEmail(String userId, String email);

  /// Update user photo
  Future<Result<User>> updateUserPhoto(String userId, String photoUrl);

  /// Delete user photo
  Future<Result<User>> deleteUserPhoto(String userId);

  /// Get user statistics
  Future<Result<Map<String, dynamic>>> getUserStats(String userId);

  /// Get user plans
  Future<Result<List<Plan>>> getUserPlans(String userId);

  /// Get user favorites
  Future<Result<List<Plan>>> getUserFavorites(String userId);

  /// Update user premium status
  Future<Result<User>> updateUserPremiumStatus(String userId, bool isPremium);

  /// Follow a user
  Future<Result<Map<String, dynamic>>> followUser(String targetUserId);

  /// Unfollow a user
  Future<Result<Map<String, dynamic>>> unfollowUser(String targetUserId);

  /// Get user followers
  Future<Result<List<User>>> getUserFollowers(String userId);

  /// Get users that a user is following
  Future<Result<List<User>>> getUserFollowing(String userId);

  /// Check if a user is following another user
  Future<Result<Map<String, dynamic>>> checkFollowing(
      String followerId, String targetId);
}
