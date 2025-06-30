import 'dart:convert';
import 'dart:io';

import 'package:front/data/services/api/model/login_request/login_request_api_model.dart';
import 'package:front/data/services/api/model/login_response/login_response_api_model.dart';
import 'package:front/data/services/api/model/register_request/register_request_api_model.dart';
import 'package:front/data/services/api/model/register_response/register_response_api_model.dart';
import 'package:front/data/services/api/model/refresh_token_request/refresh_token_request_api_model.dart';
import 'package:front/data/services/api/model/refresh_token_response/refresh_token_response_api_model.dart';
import 'package:front/core/utils/result.dart';

class AuthApiClient {
  AuthApiClient({String? host, int? port, HttpClient Function()? clientFactory})
      : _host = host ?? '192.168.1.135',
        _port = port ?? 3000,
        _clientFactory = clientFactory ?? HttpClient.new;

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;

  Future<Result<LoginResponseApiModel>> login(
      LoginRequestApiModel loginRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/login');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(loginRequest));
      final response = await request.close();
      if (response.statusCode == 201) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(
            LoginResponseApiModel.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Login error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<RegisterResponseApiModel>> register(
      RegisterRequestApiModel registerRequestApiModel) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/register');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(registerRequestApiModel));
      final response = await request.close();
      if (response.statusCode == 201) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(
            RegisterResponseApiModel.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Registration error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<RefreshTokenResponseApiModel>> refreshToken(
      RefreshTokenRequestApiModel refreshTokenRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/refresh');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(refreshTokenRequest));
      final response = await request.close();
      if (response.statusCode == 201) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(
            RefreshTokenResponseApiModel.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Refresh token error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
