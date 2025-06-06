import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/model/user/user_api_model.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/utils/result.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  User? _cachedData;

  @override
  Future<Result<User>> getUser() async {
    if (_cachedData != null) {
      return Future.value(Result.ok(_cachedData!));
    }

    final result = await _apiClient.getUser();
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
          role: result.value.role,
          isActive: result.value.isActive,
          followers: result.value.followers,
          following: result.value.following,
        );
        _cachedData = user;
        return Result.ok(user);
      case Error<UserApiModel>():
        return Result.error(result.error);
    }
  }
}
