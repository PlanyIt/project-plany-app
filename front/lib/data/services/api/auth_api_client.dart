import 'dart:convert';
import 'dart:io';

import '../../../utils/result.dart';
import 'model/auth_response/auth_response.dart';
import 'model/login_request/login_request.dart';
import 'model/register_request/register_request.dart';

class AuthApiClient {
  AuthApiClient({String? host, int? port, HttpClient Function()? clientFactory})
      : _host = host ?? 'localhost',
        _port = port ?? 8080,
        _clientFactory = clientFactory ?? HttpClient.new;

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;

  Future<Result<AuthResponse>> login(LoginRequest loginRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/login');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(loginRequest));
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(AuthResponse.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Login error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<AuthResponse>> register(RegisterRequest registerRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/register');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(registerRequest));
      final response = await request.close();
      if (response.statusCode == 201) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(AuthResponse.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Registration error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
