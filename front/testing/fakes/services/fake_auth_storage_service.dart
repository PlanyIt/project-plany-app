import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/utils/result.dart';

class FakeAuthStorageService implements AuthStorageService {
  String? accessToken;
  String? refreshToken;
  String? userJson;

  @override
  Future<(String?, String?)> fetchTokens() async {
    return (accessToken, refreshToken);
  }

  @override
  Future<void> saveTokens({
    required String? accessToken,
    required String? refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<Result<String?>> fetchUserJson() async {
    return Result.ok(userJson);
  }

  @override
  Future<Result<void>> saveUserJson(String? userJson) async {
    this.userJson = userJson;
    return const Result.ok(null);
  }
}
