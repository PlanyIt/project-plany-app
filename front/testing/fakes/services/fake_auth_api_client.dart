import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/api/model/auth_response/auth_response.dart';
import 'package:front/data/services/api/model/login_request/login_request.dart';
import 'package:front/data/services/api/model/register_request/register_request.dart';
import 'package:front/utils/result.dart';

import '../../models/user.dart';

class FakeAuthApiClient implements AuthApiClient {
  @override
  Future<Result<AuthResponse>> login(LoginRequest loginRequest) async {
    if (loginRequest.email == 'user@email.com' &&
        loginRequest.password == 'password123') {
      return Result.ok(
        AuthResponse(
          accessToken: 'fake_access_token',
          refreshToken: 'fake_refresh_token',
          currentUser: userApiModel,
        ),
      );
    }
    return Result.error(Exception('Invalid credentials'));
  }

  @override
  Future<Result<AuthResponse>> register(RegisterRequest registerRequest) async {
    if (registerRequest.email.isNotEmpty &&
        registerRequest.password.isNotEmpty) {
      return Result.ok(AuthResponse(
        accessToken: 'new_fake_access_token',
        refreshToken: 'new_fake_refresh_token',
        currentUser: userApiModel,
      ));
    }
    return Result.error(Exception('Invalid registration'));
  }

  @override
  Future<Result<AuthResponse>> refresh(String refreshToken) async {
    if (refreshToken == 'fake_refresh_token') {
      return Result.ok(AuthResponse(
        accessToken: 'refreshed_fake_access_token',
        refreshToken: 'refreshed_fake_refresh_token',
        currentUser: userApiModel,
      ));
    }
    return Result.error(Exception('Invalid refresh token'));
  }
  
  @override
  Future<Result<void>> logout(String refreshToken) {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
