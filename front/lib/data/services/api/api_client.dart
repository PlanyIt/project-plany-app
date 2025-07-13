import 'dart:convert';
import 'dart:io';

import '../../../domain/models/comment/comment.dart';
import '../../../domain/models/plan/plan.dart';
import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';
import 'model/category/category_api_model.dart';
import 'model/step/step_api_model.dart';
import 'model/user/user_api_model.dart';

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

    if (response.statusCode == 200 || response.statusCode == 201) {
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
        try {
          final json = jsonDecode(responseBody);
          if (json is Map<String, dynamic>) {
            return Result.ok(Plan.fromJson(json));
          } else {
            return Result.error(
              HttpException(
                  "Response is not a valid JSON object: $responseBody"),
            );
          }
        } catch (e) {
          return Result.error(
            HttpException(
                "Failed to parse JSON response: $e | Body: $responseBody"),
          );
        }
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

  // Add to favorites
  Future<Result<void>> addPlanToFavorites(String planId) async {
    final client = _clientFactory();
    try {
      final request = await client.put(
        _host,
        _port,
        '/api/plans/$planId/favorite',
      );
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to add plan to favorites: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> removePlanFromFavorites(String planId) async {
    final client = _clientFactory();
    try {
      final request = await client.put(
        _host,
        _port,
        '/api/plans/$planId/unfavorite',
      );
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to remove plan from favorites: ${response.statusCode} - $errorBody'),
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

  /// User endpoints

  Future<Result<UserApiModel>> getUserById(String userId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/users/$userId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(UserApiModel.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  // Comment endpoints

  Future<Result<List<Comment>>> getComments(String planId,
      {int page = 1, int limit = 10}) async {
    final client = _clientFactory();
    try {
      final request = await client.get(
          _host, _port, '/api/comments/plan/$planId?page=$page&limit=$limit');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {
          final responseData = json as Map<String, dynamic>;
          if (responseData['comments'] != null) {
            return (responseData['comments'] as List<dynamic>)
                .map((comment) => Comment.fromJson(comment))
                .toList();
          } else {
            return <Comment>[];
          }
        },
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Comment>>> getCommentResponses(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/comments/$commentId/responses');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) => (json as List<dynamic>)
            .map((response) => Comment.fromJson(response))
            .toList(),
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Comment>> createComment(String planId, Comment comment) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/comments');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      // Send only the fields that the backend expects
      final body = jsonEncode({
        'content': comment.content,
        'planId': comment.planId,
        'parentId': comment.parentId,
        'imageUrl': comment.imageUrl,
        'user': comment.user?.id,
      });
      request.write(body);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {
          final responseData = json as Map<String, dynamic>;
          if (responseData['_id'] == null) {
            throw Exception('Server did not return an ID for the comment');
          }
          return Comment.fromJson(responseData);
        },
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> editComment(String commentId, Comment comment) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      // Send only the fields that the backend expects
      final body = jsonEncode({
        'content': comment.content,
        'imageUrl': comment.imageUrl,
        'user': comment.user?.id,
        'planId': comment.planId,
      });
      request.write(body);

      final response = await request.close();
      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to edit comment: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteComment(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.delete(_host, _port, '/api/comments/$commentId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to delete comment: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Comment>> getCommentById(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/comments/$commentId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {
          final responseData = json as Map<String, dynamic>;
          if (responseData['_id'] == null) {
            throw Exception('Server did not return an ID for the comment');
          }
          return Comment.fromJson(responseData);
        },
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> likeComment(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId/like');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to like comment: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> unlikeComment(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId/unlike');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to unlike comment: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Comment>> respondToComment(
      String commentId, Comment comment) async {
    final client = _clientFactory();
    try {
      final request = await client.post(
        _host,
        _port,
        '/api/comments/$commentId/response',
      );
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final body = jsonEncode({
        'content': comment.content,
        'imageUrl': comment.imageUrl,
        'user': comment.user?.id,
        'planId': comment.planId,
      });
      request.write(body);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {
          final responseData = json as Map<String, dynamic>;
          if (responseData['_id'] == null) {
            throw Exception('Server did not return an ID for the response');
          }
          return Comment.fromJson(responseData);
        },
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteResponse(
      String commentId, String responseId) async {
    final client = _clientFactory();
    try {
      final request = await client.delete(
          _host, _port, '/api/comments/$commentId/response/$responseId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to delete response: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> addResponseToComment(
      String commentId, String responseId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId/responses');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final body = jsonEncode({'responseId': responseId});
      request.write(body);

      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Result.ok(null);
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        return Result.error(
          HttpException(
              'Failed to add response to comment: ${response.statusCode} - $errorBody'),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  /// User follow/unfollow endpoints

  Future<Result<void>> followUser(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.post(_host, _port, '/api/users/$userId/follow');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {},
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> unfollowUser(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.delete(_host, _port, '/api/users/$userId/follow');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) {},
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<bool>> isFollowing(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/me/following/$userId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      return await _handleResponse(
        response,
        (json) => (json as Map<String, dynamic>)['isFollowing'] as bool,
      );
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
