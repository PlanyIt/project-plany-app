import 'dart:convert';
import 'dart:io';

import 'package:front/data/services/api/model/login_request/login_request.dart';
import 'package:front/data/services/api/model/login_response/login_response.dart';
import 'package:front/utils/result.dart';

class AuthApiClient {
  AuthApiClient({String? host, int? port, HttpClient Function()? clientFactory})
      : _host = host ?? '192.168.1.135',
        _port = port ?? 3000,
        _clientFactory = clientFactory ?? HttpClient.new;

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;

  Future<Result<LoginResponse>> login(LoginRequest loginRequest) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/auth/login');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(loginRequest));
      final response = await request.close();
      if (response.statusCode == 201) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(LoginResponse.fromJson(jsonDecode(stringData)));
      } else {
        return const Result.error(HttpException("Login error"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
