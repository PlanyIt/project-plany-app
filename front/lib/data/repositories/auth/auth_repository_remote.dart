import 'dart:convert';
import 'dart:async';

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
    _apiClient.onUnauthorized = () => logout();
  }

  final AuthApiClient _authApiClient;
  final ApiClient _apiClient;
  final AuthStorageService _authStorageService;

  bool? _isAuthenticated;
  String? _authToken;
  User? _currentUser;
  DateTime? _tokenExpiration;

  final _log = Logger('AuthRepositoryRemote');

  void _checkTokenExpiration() {
    if (_tokenExpiration != null && DateTime.now().isAfter(_tokenExpiration!)) {
      _log.info('Token expired, logging out user');
      logout();
    }
  }

  DateTime _parseTokenExpiration(String token) {
    try {
      // Décoder le JWT pour extraire l'expiration
      final parts = token.split('.');
      if (parts.length != 3)
        return DateTime.now().add(const Duration(minutes: 2));

      final payload = parts[1];
      // Ajouter padding si nécessaire
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = json['exp'] as int?;
      if (exp != null) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    } catch (e) {
      _log.warning('Failed to parse token expiration: $e');
    }

    // Fallback: supposer 2 minutes d'expiration
    return DateTime.now().add(const Duration(minutes: 2));
  }

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
          _tokenExpiration = _parseTokenExpiration(result.value.token);
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
          _log.info('User logged in');
          // Set auth status
          _isAuthenticated = true;
          _authToken = result.value.token;
          _tokenExpiration = _parseTokenExpiration(result.value.token);
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
  User? get currentUser => _currentUser;

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
      _tokenExpiration = null;
      _log.info('Utilisateur déconnecté');

      return const Result.ok(null);
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _authHeaderProvider() {
    if (_authToken == null) return null;

    _checkTokenExpiration();

    return _authToken != null ? 'Bearer $_authToken' : null;
  }
}
