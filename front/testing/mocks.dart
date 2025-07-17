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
    final headers = MockHttpHeaders();

    // Configuration de la request
    when(() => request.headers).thenReturn(headers);
    when(() => request.close()).thenAnswer((_) => Future.value(response));
    when(() => request.write(any())).thenReturn(null);

    // Configuration de la response
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.transform(utf8.decoder))
        .thenAnswer((_) => Stream.fromIterable([jsonEncode(object)]));

    // Configuration des headers
    when(() => headers.add(any(), any())).thenReturn(null);
    when(() => headers.contentType = any()).thenReturn(null);

    // Mock de la méthode HTTP appropriée
    switch (method) {
      case HttpMethod.get:
        when(() => getUrl(any())).thenAnswer((_) => Future.value(request));
        break;
      case HttpMethod.post:
        when(() => postUrl(any())).thenAnswer((_) => Future.value(request));
        break;
      case HttpMethod.put:
        when(() => putUrl(any())).thenAnswer((_) => Future.value(request));
        break;
      case HttpMethod.patch:
        when(() => patchUrl(any())).thenAnswer((_) => Future.value(request));
        break;
      case HttpMethod.delete:
        when(() => deleteUrl(any())).thenAnswer((_) => Future.value(request));
        break;
    }

    // Mock de la méthode close du client
    when(() => close(force: any(named: 'force'))).thenReturn(null);
  }

  void _mockRequestThrows(HttpMethod method, String path, Exception exception) {
    switch (method) {
      case HttpMethod.get:
        when(() => getUrl(any())).thenThrow(exception);
        break;
      case HttpMethod.post:
        when(() => postUrl(any())).thenThrow(exception);
        break;
      case HttpMethod.put:
        when(() => putUrl(any())).thenThrow(exception);
        break;
      case HttpMethod.patch:
        when(() => patchUrl(any())).thenThrow(exception);
        break;
      case HttpMethod.delete:
        when(() => deleteUrl(any())).thenThrow(exception);
        break;
    }

    // Mock de la méthode close du client
    when(() => close(force: any(named: 'force'))).thenReturn(null);
  }
}
