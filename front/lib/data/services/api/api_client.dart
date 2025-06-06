import 'dart:convert';
import 'dart:io';

import 'package:front/data/services/api/model/user/user_api_model.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/utils/result.dart';

/// Adds the `Authentication` header to a header configuration.
typedef AuthHeaderProvider = String? Function();

class ApiClient {
  ApiClient({String? host, int? port, HttpClient Function()? clientFactory})
      : _host = host ?? '192.168.1.181',
        _port = port ?? 3000,
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

  Future<Result<List<Category>>> getCategories() async {
    final client = _clientFactory();
    try {
      print('Fetching categories from: $_host:$_port/api/categories');
      final request = await client.get(_host, _port, '/api/categories');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      print('Categories API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        print('Categories API raw response: $stringData');

        try {
          final json = jsonDecode(stringData);

          // Check if response is a list
          if (json is List) {
            print('Parsing ${json.length} categories');
            final categories =
                json.map((element) => Category.fromJson(element)).toList();
            return Result.ok(categories);
          } else if (json is Map) {
            // Handle case where API returns an object with a data field containing categories
            if (json.containsKey('data') && json['data'] is List) {
              print(
                  'Parsing ${json['data'].length} categories from data field');
              final categories = (json['data'] as List)
                  .map((element) => Category.fromJson(element))
                  .toList();
              return Result.ok(categories);
            } else {
              print('Unexpected JSON structure: $json');
              return const Result.error(HttpException(
                  "Invalid response format - not a list or data object"));
            }
          } else {
            print('Unexpected JSON type: ${json.runtimeType}');
            return const Result.error(
                HttpException("Invalid response format - unknown type"));
          }
        } catch (e) {
          print('Error parsing categories JSON: $e');
          return Result.error(Exception('Failed to parse categories: $e'));
        }
      } else {
        print('Categories API error: ${response.statusCode}');
        return Result.error(
            HttpException("Invalid response: ${response.statusCode}"));
      }
    } on Exception catch (error) {
      print('Categories API exception: $error');
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Category>> getCategoryById(String id) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/categories/$id');
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(Category.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<UserApiModel>> getUser() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/users');
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final jsonData = jsonDecode(stringData);

        try {
          // Handle case where API returns a list of users
          if (jsonData is List) {
            if (jsonData.isEmpty) {
              return const Result.error(HttpException("No user found"));
            }
            // Sanitize the user data before creating the model
            final sanitizedData = _sanitizeUserData(jsonData[0]);
            final user = UserApiModel.fromJson(sanitizedData);
            return Result.ok(user);
          } else {
            // Sanitize the user data before creating the model
            final sanitizedData = _sanitizeUserData(jsonData);
            final user = UserApiModel.fromJson(sanitizedData);
            return Result.ok(user);
          }
        } catch (e) {
          print('Error parsing user data: $e');
          return Result.error(Exception('Failed to parse user data: $e'));
        }
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  // Helper method to sanitize user data and ensure no null values for required string fields
  Map<String, dynamic> _sanitizeUserData(dynamic userData) {
    if (userData == null) return {};

    final Map<String, dynamic> data =
        userData is Map ? Map<String, dynamic>.from(userData) : {};

    // Ensure required string fields have default values if null
    final requiredStringFields = ['id', 'name', 'email', 'username'];
    for (final field in requiredStringFields) {
      if (data[field] == null) {
        data[field] = '';
      }
    }

    return data;
  }

  //getPlans
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
}
