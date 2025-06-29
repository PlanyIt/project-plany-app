import 'package:flutter/foundation.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';
import 'package:front/utils/exceptions.dart';
import 'package:logging/logging.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({
    required ApiClient apiClient,
    required AuthStorageService authStorageService,
  })  : _apiClient = apiClient,
        _authStorageService = authStorageService;

  final ApiClient _apiClient;
  final AuthStorageService _authStorageService;
  final _log = Logger('UserRepositoryRemote');

  User? _cachedUser;

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      if (_cachedUser != null) {
        if (kDebugMode) print('✅ Returning cached user');
        return Result.ok(_cachedUser!);
      }

      final userIdResult = await _authStorageService.fetchUserId();
      if (kDebugMode) print('🧩 SharedPreferences returned: $userIdResult');

      if (userIdResult is Error<String?>) {
        _log.warning('Failed to fetch user ID from storage');
        return Result.error(
          const StorageException('Impossible de récupérer l\'ID utilisateur'),
        );
      }

      final userId = (userIdResult as Ok<String?>).value;
      if (userId == null || userId.isEmpty) {
        _log.warning('User ID not found in SharedPreferences');
        return Result.error(
          const AuthenticationException('Utilisateur non connecté'),
        );
      }

      if (kDebugMode) print('🌐 Fetching user with ID: $userId');
      final result = await _apiClient.getUser(userId);

      if (kDebugMode) print('📦 API response: $result');

      if (result is Ok<User>) {
        _cachedUser = result.value;
        _log.info('Successfully fetched and cached current user');
        return Result.ok(_cachedUser!);
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to fetch current user: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting current user', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération de l\'utilisateur actuel'),
      );
    }
  }

  void clearUserCache() {
    if (kDebugMode) print('🧹 Clearing user cache');
    _cachedUser = null;
  }

  @override
  Future<Result<User>> patchCurrentUser(Map<String, dynamic> data) async {
    try {
      if (_cachedUser == null) {
        _log.warning('patchCurrentUser called without cached user');
        return Result.error(
          const ValidationException('Utilisateur non connecté'),
        );
      }

      if (data.isEmpty) {
        _log.warning('patchCurrentUser called with empty data');
        return Result.error(
          const ValidationException('Données de mise à jour requises'),
        );
      }

      final userId = _cachedUser!.id;

      if (kDebugMode) print('🌐 Patching user with ID: $userId');

      final result = await _apiClient.patchUser(userId, data);

      if (result is Ok<User>) {
        _cachedUser = result.value;
        _log.info('Successfully updated current user');
        return Result.ok(_cachedUser!);
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to update user: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error patching current user', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la mise à jour de l\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<User>> getUserProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserProfile called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching user profile with ID: $userId');

      final result = await _apiClient.getUser(userId);

      if (result is Ok<User>) {
        _log.info('Successfully fetched user profile: $userId');
        return Result.ok(result.value);
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to fetch user profile $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user profile: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération du profil utilisateur'),
      );
    }
  }

  @override
  Future<Result<List<User>>> getUsers() async {
    try {
      if (kDebugMode) print('🌐 Fetching all users');

      final result = await _apiClient.getUsers();

      if (result is Ok<List<User>>) {
        _log.info('Successfully fetched ${result.value.length} users');
        return result;
      } else {
        final error = (result as Error<List<User>>).error;
        _log.warning('Failed to fetch users: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting users', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des utilisateurs'),
      );
    }
  }

  @override
  Future<Result<User>> createUser(Map<String, dynamic> body) async {
    try {
      if (body.isEmpty) {
        _log.warning('createUser called with empty body');
        return Result.error(
          const ValidationException('Données utilisateur requises'),
        );
      }

      if (kDebugMode) print('🌐 Creating user with data: $body');

      final result = await _apiClient.createUser(body);

      if (result is Ok<User>) {
        _log.info('Successfully created user: ${result.value.id}');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to create user: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error creating user', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la création de l\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<void>> deleteUser(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('deleteUser called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Deleting user with ID: $userId');

      final result = await _apiClient.deleteUser(userId);

      if (result is Ok<void>) {
        _log.info('Successfully deleted user: $userId');
        if (_cachedUser?.id == userId) {
          _cachedUser = null;
        }
        return result;
      } else {
        final error = (result as Error<void>).error;
        _log.warning('Failed to delete user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error deleting user: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la suppression de l\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<User>> getUserByUsername(String username) async {
    try {
      if (username.isEmpty) {
        _log.warning('getUserByUsername called with empty username');
        return Result.error(
          const ValidationException('Nom d\'utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching user by username: $username');

      final result = await _apiClient.getUserByUsername(username);

      if (result is Ok<User>) {
        _log.info('Successfully fetched user by username: $username');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to fetch user by username $username: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting user by username: $username', e,
          stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la recherche par nom d\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<User>> getUserByEmail(String email) async {
    try {
      if (email.isEmpty) {
        _log.warning('getUserByEmail called with empty email');
        return Result.error(
          const ValidationException('Adresse email requise'),
        );
      }

      if (kDebugMode) print('🌐 Fetching user by email: $email');

      final result = await _apiClient.getUserByEmail(email);

      if (result is Ok<User>) {
        _log.info('Successfully fetched user by email: $email');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to fetch user by email $email: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user by email: $email', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la recherche par email'),
      );
    }
  }

  @override
  Future<Result<User>> updateUserEmail(String userId, String email) async {
    try {
      if (userId.isEmpty) {
        _log.warning('updateUserEmail called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (email.isEmpty) {
        _log.warning('updateUserEmail called with empty email');
        return Result.error(
          const ValidationException('Adresse email requise'),
        );
      }

      if (kDebugMode) print('🌐 Updating email for user: $userId');

      final result = await _apiClient.updateUserEmail(userId, email);

      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }

      if (result is Ok<User>) {
        _log.info('Successfully updated email for user: $userId');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to update email for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error updating user email: $userId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la mise à jour de l\'email'),
      );
    }
  }

  @override
  Future<Result<User>> updateUserPhoto(String userId, String photoUrl) async {
    try {
      if (userId.isEmpty) {
        _log.warning('updateUserPhoto called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (photoUrl.isEmpty) {
        _log.warning('updateUserPhoto called with empty photoUrl');
        return Result.error(
          const ValidationException('URL de photo requise'),
        );
      }

      if (kDebugMode) print('🌐 Updating photo for user: $userId');

      final result = await _apiClient.updateUserPhoto(userId, photoUrl);

      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }

      if (result is Ok<User>) {
        _log.info('Successfully updated photo for user: $userId');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to update photo for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error updating user photo: $userId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la mise à jour de la photo'),
      );
    }
  }

  @override
  Future<Result<User>> deleteUserPhoto(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('deleteUserPhoto called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Deleting photo for user: $userId');

      final result = await _apiClient.deleteUserPhoto(userId);

      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }

      if (result is Ok<User>) {
        _log.info('Successfully deleted photo for user: $userId');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning('Failed to delete photo for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error deleting user photo: $userId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la suppression de la photo'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserStats(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserStats called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching stats for user: $userId');

      final result = await _apiClient.getUserStats(userId);

      if (result is Ok<Map<String, dynamic>>) {
        _log.info('Successfully fetched stats for user: $userId');
        return result;
      } else {
        final error = (result as Error<Map<String, dynamic>>).error;
        _log.warning('Failed to fetch stats for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user stats: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des statistiques'),
      );
    }
  }

  @override
  Future<Result<List<Plan>>> getUserPlans(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserPlans called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching plans for user: $userId');

      final result = await _apiClient.getUserPlans(userId);

      if (result is Ok<List<Plan>>) {
        _log.info(
            'Successfully fetched ${result.value.length} plans for user: $userId');
        return result;
      } else {
        final error = (result as Error<List<Plan>>).error;
        _log.warning('Failed to fetch plans for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user plans: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des plans utilisateur'),
      );
    }
  }

  @override
  Future<Result<List<Plan>>> getUserFavorites(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserFavorites called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching favorites for user: $userId');

      final result = await _apiClient.getUserFavorites(userId);

      if (result is Ok<List<Plan>>) {
        _log.info(
            'Successfully fetched ${result.value.length} favorites for user: $userId');
        return result;
      } else {
        final error = (result as Error<List<Plan>>).error;
        _log.warning('Failed to fetch favorites for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user favorites: $userId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des favoris'),
      );
    }
  }

  @override
  Future<Result<User>> updateUserPremiumStatus(
      String userId, bool isPremium) async {
    try {
      if (userId.isEmpty) {
        _log.warning('updateUserPremiumStatus called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode)
        print('🌐 Updating premium status for user: $userId to $isPremium');

      final result =
          await _apiClient.updateUserPremiumStatus(userId, isPremium);

      if (result is Ok<User> && _cachedUser?.id == userId) {
        _cachedUser = result.value;
      }

      if (result is Ok<User>) {
        _log.info('Successfully updated premium status for user: $userId');
        return result;
      } else {
        final error = (result as Error<User>).error;
        _log.warning(
            'Failed to update premium status for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error updating user premium status: $userId', e,
          stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la mise à jour du statut premium'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> followUser(String targetUserId) async {
    try {
      if (targetUserId.isEmpty) {
        _log.warning('followUser called with empty targetUserId');
        return Result.error(
          const ValidationException('ID utilisateur cible requis'),
        );
      }

      if (kDebugMode) print('🌐 Following user: $targetUserId');

      final result = await _apiClient.followUser(targetUserId);

      if (result is Ok<Map<String, dynamic>>) {
        _log.info('Successfully followed user: $targetUserId');
        return result;
      } else {
        final error = (result as Error<Map<String, dynamic>>).error;
        _log.warning('Failed to follow user $targetUserId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error following user: $targetUserId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors du suivi de l\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> unfollowUser(String targetUserId) async {
    try {
      if (targetUserId.isEmpty) {
        _log.warning('unfollowUser called with empty targetUserId');
        return Result.error(
          const ValidationException('ID utilisateur cible requis'),
        );
      }

      if (kDebugMode) print('🌐 Unfollowing user: $targetUserId');

      final result = await _apiClient.unfollowUser(targetUserId);

      if (result is Ok<Map<String, dynamic>>) {
        _log.info('Successfully unfollowed user: $targetUserId');
        return result;
      } else {
        final error = (result as Error<Map<String, dynamic>>).error;
        _log.warning('Failed to unfollow user $targetUserId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error unfollowing user: $targetUserId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de l\'arrêt du suivi de l\'utilisateur'),
      );
    }
  }

  @override
  Future<Result<List<User>>> getUserFollowers(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserFollowers called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching followers for user: $userId');

      final result = await _apiClient.getUserFollowers(userId);

      if (result is Ok<List<User>>) {
        _log.info(
            'Successfully fetched ${result.value.length} followers for user: $userId');
        return result;
      } else {
        final error = (result as Error<List<User>>).error;
        _log.warning('Failed to fetch followers for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user followers: $userId', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des abonnés'),
      );
    }
  }

  @override
  Future<Result<List<User>>> getUserFollowing(String userId) async {
    try {
      if (userId.isEmpty) {
        _log.warning('getUserFollowing called with empty userId');
        return Result.error(
          const ValidationException('ID utilisateur requis'),
        );
      }

      if (kDebugMode) print('🌐 Fetching following for user: $userId');

      final result = await _apiClient.getUserFollowing(userId);

      if (result is Ok<List<User>>) {
        _log.info(
            'Successfully fetched ${result.value.length} following for user: $userId');
        return result;
      } else {
        final error = (result as Error<List<User>>).error;
        _log.warning('Failed to fetch following for user $userId: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting user following: $userId', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération des abonnements'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> checkFollowing(
      String followerId, String targetId) async {
    try {
      if (followerId.isEmpty) {
        _log.warning('checkFollowing called with empty followerId');
        return Result.error(
          const ValidationException('ID du suiveur requis'),
        );
      }

      if (targetId.isEmpty) {
        _log.warning('checkFollowing called with empty targetId');
        return Result.error(
          const ValidationException('ID utilisateur cible requis'),
        );
      }

      if (kDebugMode)
        print('🌐 Checking if user $followerId follows $targetId');

      final result = await _apiClient.checkFollowing(followerId, targetId);

      if (result is Ok<Map<String, dynamic>>) {
        _log.info('Successfully checked following status');
        return result;
      } else {
        final error = (result as Error<Map<String, dynamic>>).error;
        _log.warning('Failed to check following status: $error');
        return Result.error(error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error checking following status', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la vérification du statut de suivi'),
      );
    }
  }
}
