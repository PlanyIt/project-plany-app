import 'dart:convert';

import 'package:logging/logging.dart';

import '../../../domain/models/user/user.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/auth_api_client.dart';
import '../../services/api/model/auth_response/auth_response.dart';
import '../../services/api/model/login_request/login_request.dart';
import '../../services/api/model/register_request/register_request.dart';
import '../../services/auth_storage_service.dart';
import 'auth_repository.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required ApiClient apiClient,
    required AuthApiClient authApiClient,
    required AuthStorageService authStorageService,
  })  : _apiClient = apiClient,
        _authApiClient = authApiClient,
        _authStorageService = authStorageService {
    _apiClient.authHeaderProvider = _authHeaderProvider;
  }

  final AuthApiClient _authApiClient;
  final ApiClient _apiClient;
  final AuthStorageService _authStorageService;

  bool? _isAuthenticated;
  String? _authToken;
  User? _currentUser;

  User? get currentUser => _currentUser;

  final _log = Logger('AuthRepositoryRemote');

  /// Charge token et user JSON depuis le storage.
  Future<void> _fetch() async {
    // 1) token
    final tokenRes = await _authStorageService.fetchToken();
    if (tokenRes is Ok<String?>) {
      _authToken = tokenRes.value;
      _isAuthenticated = _authToken != null;
    } else if (tokenRes is Error<String?>) {
      _log.severe('Échec fetchToken: ${tokenRes.error}');
    }

    // 2) user JSON
    final userJsonRes = await _authStorageService.fetchUserJson();
    if (userJsonRes is Ok<String?> && userJsonRes.value != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJsonRes.value!));
      } catch (e, st) {
        _log.severe('Erreur désérialisation user JSON', e, st);
      }
    } else if (userJsonRes is Error<String?>) {
      _log.warning('Échec fetchUserJson: ${userJsonRes.error}');
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    // Status is cached
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    // No status cached, fetch from storage
    await _fetch();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Result<void>> register(
      {required String email,
      required String username,
      required String password}) async {
    try {
      final result = await _authApiClient.register(RegisterRequest(
          username: username, email: email, password: password));
      switch (result) {
        case Ok<AuthResponse>():
          _log.info('User registered successfully');
          // Set auth status
          _isAuthenticated = true;
          _authToken = result.value.token;
          _currentUser = User(
            id: result.value.currentUser.id,
            username: result.value.currentUser.username,
            email: result.value.currentUser.email,
            description: result.value.currentUser.description,
            isPremium: result.value.currentUser.isPremium,
            photoUrl: result.value.currentUser.photoUrl,
            birthDate: result.value.currentUser.birthDate,
          );
          // Store in storage
          await _authStorageService.saveToken(result.value.token);
          await _authStorageService.saveUserJson(
            jsonEncode(result.value.currentUser.toJson()),
          );
          _log.info('Utilisateur connecté: ${result.value.currentUser.id}');
          return const Result.ok(null);
        case Error<AuthResponse>():
          _log.warning('Error registering user: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authApiClient.login(
        LoginRequest(email: email, password: password),
      );
      switch (result) {
        case Ok<AuthResponse>():
          _log.info('User logged int');
          // Set auth status
          _isAuthenticated = true;
          _authToken = result.value.token;
          _currentUser = User(
            id: result.value.currentUser.id,
            username: result.value.currentUser.username,
            email: result.value.currentUser.email,
            description: result.value.currentUser.description,
            isPremium: result.value.currentUser.isPremium,
            photoUrl: result.value.currentUser.photoUrl,
            birthDate: result.value.currentUser.birthDate,
          );
          // Store in storage
          await _authStorageService.saveToken(result.value.token);
          await _authStorageService.saveUserJson(
            jsonEncode(result.value.currentUser.toJson()),
          );
          _log.info('Utilisateur connecté: ${result.value.currentUser.id}');
          return const Result.ok(null);
        case Error<AuthResponse>():
          _log.warning('Error logging in: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async {
    _log.info('User logged out');
    try {
      // Clear stored auth token
      await _authStorageService.saveToken(null);
      await _authStorageService.saveUserJson(null);

      _authToken = null;
      _currentUser = null;
      _isAuthenticated = false;
      _log.info('Utilisateur déconnecté');

      return const Result.ok(null);
    } finally {
      notifyListeners();
    }
  }

  String? _authHeaderProvider() =>
      _authToken != null ? 'Bearer $_authToken' : null;
}
