import 'dart:convert';
import 'dart:io';

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

  set authHeaderProvider(AuthHeaderProvider authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  Future<void> _authHeader(HttpHeaders headers) async {
    final header = _authHeaderProvider?.call();
    if (header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
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

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        final categories = json
            .map((category) => CategoryApiModel.fromJson(category))
            .toList();

        return Result.ok(categories);
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
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
}
