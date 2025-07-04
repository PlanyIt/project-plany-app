import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/user/user_api_model.dart';
import 'user_repository.dart';

/// Remote data source for [User].
/// Implements basic in-memory caching.
class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  User? _cachedCurrentUser;

  @override
  Future<Result<User>> getUser() async {
    try {
      final result = await _apiClient.getCurrentUser();
      switch (result) {
        case Ok<UserApiModel>():
          _cachedCurrentUser = User(
            id: result.value.id,
            username: result.value.username,
            email: result.value.email,
            profilePicture: result.value.profilePicture,
            // Ajoutez d'autres champs selon votre modèle User
          );
          return Result.ok(_cachedCurrentUser!);
        case Error<UserApiModel>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<User>> getUserProfile(String userId) async {
    try {
      final result = await _apiClient.getUserProfile(userId);
      switch (result) {
        case Ok<UserApiModel>():
          final user = User(
            id: result.value.id,
            username: result.value.username,
            email: result.value.email,
            profilePicture: result.value.profilePicture,
            // Ajoutez d'autres champs selon votre modèle User
          );
          return Result.ok(user);
        case Error<UserApiModel>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<List<User>>> getUserFollowers(String userId) async {
    try {
      final result = await _apiClient.getUserFollowers(userId);
      switch (result) {
        case Ok<List<UserApiModel>>():
          final users = result.value
              .map((userApi) => User(
                    id: userApi.id,
                    username: userApi.username,
                    email: userApi.email,
                    profilePicture: userApi.profilePicture,
                  ))
              .toList();
          return Result.ok(users);
        case Error<List<UserApiModel>>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<List<User>>> getUserFollowing(String userId) async {
    try {
      final result = await _apiClient.getUserFollowing(userId);
      switch (result) {
        case Ok<List<UserApiModel>>():
          final users = result.value
              .map((userApi) => User(
                    id: userApi.id,
                    username: userApi.username,
                    email: userApi.email,
                    profilePicture: userApi.profilePicture,
                  ))
              .toList();
          return Result.ok(users);
        case Error<List<UserApiModel>>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<void>> followUser(String userId) async {
    try {
      final result = await _apiClient.followUser(userId);
      return result;
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<void>> unfollowUser(String userId) async {
    try {
      final result = await _apiClient.unfollowUser(userId);
      return result;
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    try {
      final result = await _apiClient.isFollowing(userId);
      return result;
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
