import 'dart:convert';
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

/// ----------------------
/// Mocks pour GoRouter
/// ----------------------
class MockGoRouter extends Mock implements GoRouter {}

class FakeGoRouteInformationProvider extends Fake
    implements GoRouteInformationProvider {}

/// ----------------------
/// Mocks pour HttpClient
/// ----------------------
class MockHttpClient extends Mock implements HttpClient {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

/// ----------------------
/// Enum pour HTTP Methods
/// ----------------------
enum HttpMethod { get, post, put, patch, delete }

/// ----------------------
/// Extensions utilitaires pour MockHttpClient
/// ----------------------
extension HttpMethodMocks on MockHttpClient {
  void mockGet(String path, Object object, [int statusCode = 200]) =>
      _mockRequest(HttpMethod.get, path, object, statusCode);

  void mockPost(String path, Object object, [int statusCode = 201]) =>
      _mockRequest(HttpMethod.post, path, object, statusCode);

  void mockPut(String path, Object object, [int statusCode = 200]) =>
      _mockRequest(HttpMethod.put, path, object, statusCode);

  void mockPatch(String path, Object object, [int statusCode = 200]) =>
      _mockRequest(HttpMethod.patch, path, object, statusCode);

  void mockDelete(String path, Object object, [int statusCode = 204]) =>
      _mockRequest(HttpMethod.delete, path, object, statusCode);

  void mockGetThrows(String path, Exception exception) =>
      _mockRequestThrows(HttpMethod.get, path, exception);

  void mockPostThrows(String path, Exception exception) =>
      _mockRequestThrows(HttpMethod.post, path, exception);

  void mockPutThrows(String path, Exception exception) =>
      _mockRequestThrows(HttpMethod.put, path, exception);

  void mockPatchThrows(String path, Exception exception) =>
      _mockRequestThrows(HttpMethod.patch, path, exception);

  void mockDeleteThrows(String path, Exception exception) =>
      _mockRequestThrows(HttpMethod.delete, path, exception);

  void _mockRequest(
      HttpMethod method, String path, Object object, int statusCode) {
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();

    when(() => request.close()).thenAnswer((_) => Future.value(response));
    when(() => request.headers).thenReturn(MockHttpHeaders());
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.transform(utf8.decoder))
        .thenAnswer((_) => Stream.fromIterable([jsonEncode(object)]));

    // Mock des méthodes URL-based (utilisées par votre ApiClient)
    when(() => _mockUrlMethod(method, path))
        .thenAnswer((_) => Future.value(request));
  }

  void _mockRequestThrows(HttpMethod method, String path, Exception exception) {
    when(() => _mockUrlMethod(method, path)).thenThrow(exception);
  }

  Future<HttpClientRequest> _mockUrlMethod(HttpMethod method, String path) {
    switch (method) {
      case HttpMethod.get:
        return getUrl(any(that: _uriMatcher(path)));
      case HttpMethod.post:
        return postUrl(any(that: _uriMatcher(path)));
      case HttpMethod.put:
        return putUrl(any(that: _uriMatcher(path)));
      case HttpMethod.patch:
        return patchUrl(any(that: _uriMatcher(path)));
      case HttpMethod.delete:
        return deleteUrl(any(that: _uriMatcher(path)));
    }
  }

  Matcher _uriMatcher(String expectedPath) {
    return predicate<Uri>((uri) => uri.path.endsWith(expectedPath),
        'Uri with path ending with "$expectedPath"');
  }
}