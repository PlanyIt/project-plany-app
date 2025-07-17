import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../utils/result.dart';
import 'model/auth_response/auth_response.dart';
import 'model/login_request/login_request.dart';
import 'model/register_request/register_request.dart';

class AuthApiClient {
  AuthApiClient({String? host, HttpClient Function()? clientFactory})
      : _host = host ?? 'localhost',
        _clientFactory = clientFactory ?? HttpClient.new;

  final String _host;
  final HttpClient Function() _clientFactory;

  Uri _buildUri(String path) {
    final isLocalhost = _host.contains('localhost') || _host.contains('192.') || _host.contains('127.') || _host.contains(':3000') || _host.contains(':4000');
    if (isLocalhost) {
      return Uri.http(_host, path);
    } else {
      return Uri.https(_host, path);
    }
  }

  Future<Result<AuthResponse>> login(LoginRequest loginRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.postUrl(_buildUri('/api/auth/login'));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(loginRequest));
      final response = await request.close();
      if (response.statusCode == 201) {
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
      final request = await client.postUrl(_buildUri('/api/auth/register'));
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

  Future<Result<AuthResponse>> refresh(String refreshToken) async {
    final client = _clientFactory();
    try {
      final req = await client.postUrl(_buildUri('/api/auth/refresh'));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({'refreshToken': refreshToken}));
      final res = await req.close();

      if (res.statusCode == 200) {
        final data = await res.transform(utf8.decoder).join();
        return Result.ok(AuthResponse.fromJson(jsonDecode(data)));
      }
      return const Result.error(HttpException('Refresh error'));
    } catch (e) {
      return Result.error(Exception('Failed to refresh token: $e'));
    } finally {
      client.close();
    }
  }
}
