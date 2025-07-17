import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/api/model/auth_response/auth_response.dart';
import 'package:front/data/services/api/model/login_request/login_request.dart';
import 'package:front/data/services/api/model/register_request/register_request.dart';
import 'package:front/utils/result.dart';
import 'package:mocktail/mocktail.dart';

import '../../../testing/models/user.dart';
import '../../../testing/utils/result.dart';

class FakeHttpHeaders extends Mock implements HttpHeaders {}

class FakeHttpClient implements HttpClient {
  final FakeHttpClientRequest request;
  FakeHttpClient(this.request);

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async =>
      request;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  final FakeHttpClientResponse response;
  String? written;
  FakeHttpClientRequest(this.response);

  @override
  void write(Object? obj) {
    written = obj?.toString();
  }

  @override
  HttpHeaders get headers => FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => response;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String body;
  FakeHttpClientResponse(this.statusCode, this.body);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final bytes = utf8.encode(body);
    return Stream<List<int>>.fromIterable([bytes]).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  X509Certificate? get certificate => throw UnimplementedError();

  @override
  HttpClientResponseCompressionState get compressionState =>
      throw UnimplementedError();

  @override
  HttpConnectionInfo? get connectionInfo => throw UnimplementedError();

  @override
  int get contentLength => throw UnimplementedError();

  @override
  List<Cookie> get cookies => throw UnimplementedError();

  @override
  Future<Socket> detachSocket() {
    throw UnimplementedError();
  }

  @override
  HttpHeaders get headers => throw UnimplementedError();

  @override
  bool get isRedirect => throw UnimplementedError();

  @override
  bool get persistentConnection => throw UnimplementedError();

  @override
  String get reasonPhrase => throw UnimplementedError();

  @override
  Future<HttpClientResponse> redirect(
      [String? method, Uri? url, bool? followLoops]) {
    throw UnimplementedError();
  }

  @override
  List<RedirectInfo> get redirects => throw UnimplementedError();
}

void main() {
  final user = userApiModel;
  final authResponse = AuthResponse(
    accessToken: 'token',
    refreshToken: 'refresh',
    currentUser: user,
  );
  final authResponseJson = jsonEncode(authResponse.toJson());

  test('login returns AuthResponse on 201', () async {
    final fakeResponse = FakeHttpClientResponse(201, authResponseJson);
    final fakeRequest = FakeHttpClientRequest(fakeResponse);
    final client =
        AuthApiClient(clientFactory: () => FakeHttpClient(fakeRequest));
    final result = await client.login(LoginRequest(email: 'e', password: 'p'));
    expect(result, isA<Ok<AuthResponse>>());
    expect(result.asOk.value.accessToken, authResponse.accessToken);
    expect(result.asOk.value.refreshToken, authResponse.refreshToken);
    expect(result.asOk.value.currentUser.id, authResponse.currentUser.id);
  });

  test('register returns AuthResponse on 201', () async {
    final fakeResponse = FakeHttpClientResponse(201, authResponseJson);
    final fakeRequest = FakeHttpClientRequest(fakeResponse);
    final client =
        AuthApiClient(clientFactory: () => FakeHttpClient(fakeRequest));
    final result = await client
        .register(RegisterRequest(username: 'u', email: 'e', password: 'p'));
    expect(result, isA<Ok<AuthResponse>>());
    expect(result.asOk.value.accessToken, authResponse.accessToken);
    expect(result.asOk.value.refreshToken, authResponse.refreshToken);
    expect(result.asOk.value.currentUser.id, authResponse.currentUser.id);
  });

  test('refresh returns AuthResponse on 200', () async {
    final fakeResponse = FakeHttpClientResponse(200, authResponseJson);
    final fakeRequest = FakeHttpClientRequest(fakeResponse);
    final client =
        AuthApiClient(clientFactory: () => FakeHttpClient(fakeRequest));
    final result = await client.refresh('refresh');
    expect(result, isA<Ok<AuthResponse>>());
    expect(result.asOk.value.accessToken, authResponse.accessToken);
    expect(result.asOk.value.refreshToken, authResponse.refreshToken);
    expect(result.asOk.value.currentUser.id, authResponse.currentUser.id);
  });
}
