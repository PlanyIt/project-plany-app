import 'dart:async';
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
      if (parts.length != 3) {
        return DateTime.now().add(const Duration(minutes: 2));
      }

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

      if (_authToken != null) {
        _tokenExpiration = _parseTokenExpiration(_authToken!);
      }
    } else if (tokenRes is Error<String?>) {
      _log.severe('Échec fetchToken: ${tokenRes.error}');
    }

    // 2) user JSON
    final userJsonRes = await _authStorageService.fetchUserJson();
    if (userJsonRes is Ok<String?> && userJsonRes.value != null) {
      try {
        final userMap = jsonDecode(userJsonRes.value!) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
        _log.info('User loaded from storage: ${_currentUser?.username}');
      } catch (e, st) {
        _log.severe('Erreur désérialisation user JSON', e, st);
        // Nettoyer le cache corrompu
        await _authStorageService.saveUserJson(null);
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
          await _setAuthState(result.value);
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
          await _setAuthState(result.value);
          return const Result.ok(null);
        case Error<AuthResponse>():
          _log.warning('Error logging in: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> _setAuthState(AuthResponse authResponse) async {
    // Set auth status
    _isAuthenticated = true;
    _authToken = authResponse.token;
    _tokenExpiration = _parseTokenExpiration(authResponse.token);

    _currentUser = User(
      id: authResponse.currentUser.id,
      username: authResponse.currentUser.username,
      email: authResponse.currentUser.email,
      description: authResponse.currentUser.description,
      isPremium: authResponse.currentUser.isPremium,
      photoUrl: authResponse.currentUser.photoUrl,
      birthDate: authResponse.currentUser.birthDate,
    );

    // Store in storage
    await _authStorageService.saveToken(authResponse.token);
    await _authStorageService.saveUserJson(jsonEncode(_currentUser!.toJson()));

    _log.info('Utilisateur connecté: ${authResponse.currentUser.id}');
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

  String? _authHeaderProvider() {
    if (_authToken == null) return null;

    _checkTokenExpiration();

    return _authToken != null ? 'Bearer $_authToken' : null;
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    if (_currentUser != null) {
      _log.info('Current user already loaded: ${_currentUser!.id}');
      return Result.ok(_currentUser!);
    }

    // Essayer de recharger depuis le storage
    await _fetch();

    if (_currentUser != null) {
      _log.info('Current user loaded from storage: ${_currentUser!.id}');
      return Result.ok(_currentUser!);
    }

    return Result.error(Exception('No current user loaded'));
  }
}
