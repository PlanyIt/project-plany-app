import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/user/user_api_model.dart';
import 'user_repository.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

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
    return _apiClient.unfollowUser(userId);
  }

  @override
  Future<Result<bool>> isFollowing(String userId) async {
    return _apiClient.isFollowing(userId);
  }
}
