import 'dart:convert';
import 'dart:io';

import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';
import 'model/category/category_api_model.dart';
import 'model/step/step_api_model.dart';

/// Adds the `Authentication` header to a header configuration.
typedef AuthHeaderProvider = String? Function();

class ApiClient {
  ApiClient({String? host, int? port, HttpClient Function()? clientFactory})
      : _host = host ?? 'localhost',
        _port = port ?? 8080,
        _clientFactory = clientFactory ?? HttpClient.new;

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;

  AuthHeaderProvider? _authHeaderProvider;
  void Function()? _onUnauthorized;

  set authHeaderProvider(AuthHeaderProvider authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  set onUnauthorized(void Function() callback) {
    _onUnauthorized = callback;
  }

  Future<void> _authHeader(HttpHeaders headers) async {
    final header = _authHeaderProvider?.call();
    if (header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
    }
  }

  Future<Result<T>> _handleResponse<T>(
    HttpClientResponse response,
    T Function(dynamic) parser,
  ) async {
    if (response.statusCode == 401) {
      _onUnauthorized?.call();
      return const Result.error(HttpException("Unauthorized"));
    }

    if (response.statusCode == 200) {
      final stringData = await response.transform(utf8.decoder).join();
      return Result.ok(parser(jsonDecode(stringData)));
    } else {
      return const Result.error(HttpException("Invalid response"));
    }
  }

  // Category endpoints

  Future<Result<List<CategoryApiModel>>> getCategories() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/categories');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) => (json as List<dynamic>)
            .map((category) => CategoryApiModel.fromJson(category))
            .toList(),
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<CategoryApiModel>> getCategory(String id) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/categories/$id');
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final category = CategoryApiModel.fromJson(jsonDecode(stringData));
        return Result.ok(category);
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  // Plan endpoints
  Future<Result<List<Plan>>> getPlans() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/plans');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => Plan.fromJson(element)).toList(),
        );
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Plan>> createPlan({required Map<String, dynamic> body}) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/plans');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        final json = jsonDecode(responseBody);
        return Result.ok(Plan.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Invalid response: ${response.statusCode} | $responseBody"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  // Step endpoints
  Future<Result<List<StepApiModel>>> getStepsByPlan(String planId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(
        _host,
        _port,
        'api/steps/plan/$planId',
      );
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        final steps =
            json.map((element) => StepApiModel.fromJson(element)).toList();
        return Result.ok(steps);
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Step>> createStep(
    Step step,
    String userId,
  ) async {
    final client = _clientFactory();
    try {
      final request = await client.post(
        _host,
        _port,
        '/api/steps',
      );
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final body = jsonEncode({
        'title': step.title,
        'description': step.description,
        'longitude': step.longitude ?? 0.0,
        'latitude': step.latitude ?? 0.0,
        'order': step.order,
        'image': step.image,
        'duration': step.duration,
        'cost': step.cost,
        'userId': userId,
      });

      request.write(body);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        final json = jsonDecode(stringData);
        return Result.ok(Step.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
