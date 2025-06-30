import 'dart:convert';
import 'dart:io';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

typedef AuthHeaderProvider = String? Function();

class ApiClient {
  ApiClient({
    String? host,
    int? port,
    HttpClient Function()? clientFactory,
    AuthRepository? authRepository,
  })  : _host = host ?? '192.168.1.135',
        _port = port ?? 3000,
        _clientFactory = clientFactory ?? HttpClient.new,
        _authRepository = authRepository;

  final String _host;
  final int _port;
  final HttpClient Function() _clientFactory;
  final AuthRepository? _authRepository;
  final _log = Logger('ApiClient');

  AuthHeaderProvider? authHeaderProvider;

  Future<HttpClientResponse> _makeAuthenticatedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final client = _clientFactory();

    try {
      // Vérifier l'authentification et rafraîchir si nécessaire
      if (_authRepository != null) {
        final isAuth = await _authRepository!.isAuthenticated;
        if (!isAuth) {
          throw const HttpException('Not authenticated');
        }
      }

      late HttpClientRequest request;
      switch (method.toUpperCase()) {
        case 'GET':
          request = await client.get(_host, _port, path);
          break;
        case 'POST':
          request = await client.post(_host, _port, path);
          break;
        case 'PUT':
          request = await client.put(_host, _port, path);
          break;
        case 'PATCH':
          request = await client.patch(_host, _port, path);
          break;
        case 'DELETE':
          request = await client.delete(_host, _port, path);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      // Headers
      request.headers.contentType = ContentType.json;
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.add(key, value);
        });
      }

      // Auth header
      final authHeader = authHeaderProvider?.call();
      if (authHeader != null) {
        request.headers.add('Authorization', authHeader);
      }

      // Body
      if (body != null) {
        request.write(jsonEncode(body));
      }

      return await request.close();
    } finally {
      client.close();
    }
  }

  Future<void> _authHeader(HttpHeaders headers) async {
    final header = authHeaderProvider?.call();
    if (header != null) {
      headers.add(HttpHeaders.authorizationHeader, header);
    }
  }

  // User endpoints

  Future<Result<User>> getUser(String userId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/users/$userId');
      await _authHeader(request.headers);
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final jsonData = jsonDecode(stringData);

        try {
          final user = User.fromJson(jsonData);
          return Result.ok(user);
        } catch (e) {
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

  Future<Result<User>> patchUser(
      String userId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request =
          await client.patch(_host, _port, '/api/users/$userId/profile');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Invalid response: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<User>>> getUsers() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/users');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => User.fromJson(element)).toList(),
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

  Future<Result<User>> createUser(Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/users');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Create user failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteUser(String userId) async {
    final client = _clientFactory();
    try {
      final request = await client.delete(_host, _port, '/api/users/$userId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(HttpException("Delete user failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<User>> getUserByUsername(String username) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/username/$username');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<User>> getUserByEmail(String email) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/users/email/$email');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<User>> updateUserEmail(String userId, String email) async {
    final client = _clientFactory();
    try {
      final request =
          await client.patch(_host, _port, '/api/users/$userId/email');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode({'email': email});
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update email failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<User>> updateUserPhoto(String userId, String photoUrl) async {
    final client = _clientFactory();
    try {
      final request =
          await client.patch(_host, _port, '/api/users/$userId/photo');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode({'photoUrl': photoUrl});
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update photo failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<User>> deleteUserPhoto(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.delete(_host, _port, '/api/users/$userId/photo');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return const Result.error(HttpException("Delete photo failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> getUserStats(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/$userId/stats');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(json);
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Plan>>> getUserPlans(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/$userId/plans');
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

  Future<Result<List<Plan>>> getUserFavorites(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/$userId/favorites');
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

  Future<Result<User>> updateUserPremiumStatus(
      String userId, bool isPremium) async {
    final client = _clientFactory();
    try {
      final request =
          await client.patch(_host, _port, '/api/users/$userId/premium');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode({'isPremium': isPremium});
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(User.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update premium status failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> followUser(String targetUserId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.post(_host, _port, '/api/users/$targetUserId/follow');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(stringData);
        return Result.ok(json);
      } else {
        return Result.error(
          HttpException(
              "Follow user failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> unfollowUser(String targetUserId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.delete(_host, _port, '/api/users/$targetUserId/follow');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(json);
      } else {
        return const Result.error(HttpException("Unfollow user failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<User>>> getUserFollowers(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/$userId/followers');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => User.fromJson(element)).toList(),
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

  Future<Result<List<User>>> getUserFollowing(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/users/$userId/following');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => User.fromJson(element)).toList(),
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

  Future<Result<Map<String, dynamic>>> checkFollowing(
      String followerId, String targetId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(
          _host, _port, '/api/users/$followerId/following/$targetId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(json);
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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

  Future<Result<Plan>> getPlanById(String id) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/plans/$id');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData);
        return Result.ok(Plan.fromJson(json));
      } else {
        return const Result.error(HttpException("Invalid response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Plan>> updatePlan(
      String planId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request = await client.put(_host, _port, '/api/plans/$planId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(Plan.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update plan failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deletePlan(String planId) async {
    final client = _clientFactory();
    try {
      final request = await client.delete(_host, _port, '/api/plans/$planId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(HttpException("Delete plan failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> addPlanToFavorites(String planId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/plans/$planId/favorite');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(json);
      } else {
        return Result.error(
          HttpException(
              "Add to favorites failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> removePlanFromFavorites(
      String planId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/plans/$planId/unfavorite');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(json);
      } else {
        return Result.error(
          HttpException(
              "Remove from favorites failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Plan>>> getPlansByUserId(String userId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/plans/user/$userId');
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

  Future<Result<List<Plan>>> getFavoritesByUserId(String userId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/plans/user/$userId/favorites');
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

  // Step endpoints

  Future<Result<Step>> getStepById(String id) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/steps/$id');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();

        try {
          final json = jsonDecode(stringData);
          final step = Step.fromJson(json);
          return Result.ok(step);
        } catch (e) {
          return Result.error(Exception('Failed to parse step: $e'));
        }
      } else {
        return Result.error(
            HttpException("Invalid response: ${response.statusCode}"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Step>>> getSteps() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/steps');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => Step.fromJson(element)).toList(),
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

  Future<Result<void>> deleteStep(String stepId) async {
    final client = _clientFactory();
    try {
      final request = await client.delete(_host, _port, '/api/steps/$stepId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(HttpException("Delete step failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Step>>> getStepsByPlanId(String planId) async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/steps/plan/$planId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(
          json.map((element) => Step.fromJson(element)).toList(),
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

  Future<Result<Step>> updateStep(
      String stepId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request = await client.put(_host, _port, '/api/steps/$stepId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(Step.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update step failed: ${response.statusCode} | $stringData"),
        );
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
        'longitude': step.position?.longitude,
        'latitude': step.position?.latitude,
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

  // Category endpoints

  Future<Result<List<Category>>> getCategories() async {
    final client = _clientFactory();
    try {
      final request = await client.get(_host, _port, '/api/categories');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();

        try {
          final json = jsonDecode(stringData);

          if (json is List) {
            final categories =
                json.map((element) => Category.fromJson(element)).toList();
            return Result.ok(categories);
          } else if (json is Map) {
            if (json.containsKey('data') && json['data'] is List) {
              final categories = (json['data'] as List)
                  .map((element) => Category.fromJson(element))
                  .toList();
              return Result.ok(categories);
            } else {
              return const Result.error(HttpException(
                  "Invalid response format - not a list or data object"));
            }
          } else {
            return const Result.error(
                HttpException("Invalid response format - unknown type"));
          }
        } catch (e) {
          return Result.error(Exception('Failed to parse categories: $e'));
        }
      } else {
        return Result.error(
            HttpException("Invalid response: ${response.statusCode}"));
      }
    } on Exception catch (error) {
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

  Future<Result<Category>> createCategory(Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/categories');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(Category.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Create category failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Category>> getCategoryByName(String categoryName) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/categories/name/$categoryName');
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

  Future<Result<Category>> updateCategory(
      String categoryId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/categories/$categoryId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData);
        return Result.ok(Category.fromJson(json));
      } else {
        return Result.error(
          HttpException(
              "Update category failed: ${response.statusCode} | $stringData"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteCategory(String categoryId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.delete(_host, _port, '/api/categories/$categoryId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(HttpException("Delete category failed"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  // Comment endpoints
  Future<Result<Map<String, dynamic>>> getCommentsByPlanId(String planId,
      {int page = 1, int limit = 10}) async {
    final client = _clientFactory();
    try {
      final uri = '/api/comments/plan/$planId?page=$page&limit=$limit';
      print('🌐 Fetching comments from: $uri');
      final request = await client.get(_host, _port, uri);
      await _authHeader(request.headers);
      final response = await request.close();

      final stringData = await response.transform(utf8.decoder).join();
      print('📦 Comments API response: $stringData');

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        print('❌ Comments API error: ${response.statusCode} - $stringData');
        return Result.error(
          HttpException("Failed to get comments: ${response.statusCode}"),
        );
      }
    } on Exception catch (error) {
      print('❌ Comments API exception: $error');
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> createComment(
      Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request = await client.post(_host, _port, '/api/comments');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(
          HttpException("Failed to create comment: ${response.statusCode}"),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> getCommentById(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/comments/$commentId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(HttpException("Failed to get comment"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> updateComment(
      String commentId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(HttpException("Failed to update comment"));
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
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(HttpException("Failed to delete comment"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> likeComment(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId/like');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(HttpException("Failed to like comment"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> unlikeComment(String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.put(_host, _port, '/api/comments/$commentId/unlike');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(HttpException("Failed to unlike comment"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<Map<String, dynamic>>> addCommentResponse(
      String commentId, Map<String, dynamic> body) async {
    final client = _clientFactory();
    try {
      final request =
          await client.post(_host, _port, '/api/comments/$commentId/response');
      request.headers.contentType = ContentType.json;
      await _authHeader(request.headers);

      final encodedBody = jsonEncode(body);
      request.write(encodedBody);

      final response = await request.close();
      final stringData = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(stringData) as Map<String, dynamic>;
        return Result.ok(json);
      } else {
        return Result.error(HttpException("Failed to add comment response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getCommentResponses(
      String commentId) async {
    final client = _clientFactory();
    try {
      final request =
          await client.get(_host, _port, '/api/comments/$commentId/responses');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final json = jsonDecode(stringData) as List<dynamic>;
        return Result.ok(json.cast<Map<String, dynamic>>());
      } else {
        return Result.error(HttpException("Failed to get comment responses"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> removeCommentResponse(
      String commentId, String responseId) async {
    final client = _clientFactory();
    try {
      final request = await client.delete(
          _host, _port, '/api/comments/$commentId/response/$responseId');
      await _authHeader(request.headers);
      final response = await request.close();

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Result.ok(null);
      } else {
        return const Result.error(
            HttpException("Failed to remove comment response"));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
