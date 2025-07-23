import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

/// Implémentation distante du dépôt d'authentification.
/// Gère désormais **accessToken + refreshToken** (rotation automatique).
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

  // ────────────────────────── Dépendances ──────────────────────────
  final AuthApiClient _authApiClient;
  final ApiClient _apiClient;
  final AuthStorageService _authStorageService;

  // ────────────────────────── État interne ─────────────────────────
  bool? _isAuthenticated;
  String? _accessToken;
  String? _refreshToken;
  User? _currentUser;
  DateTime? _tokenExpiration;
  bool _isRefreshing = false;

  @visibleForTesting
  set tokenExpiration(DateTime? value) {
    _tokenExpiration = value;
  }

  final _log = Logger('AuthRepositoryRemote');

  // ────────────────────────── Utilitaires privés ───────────────────
  DateTime _parseTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return DateTime.now().add(const Duration(minutes: 2));
      }
      final payload = utf8.decode(base64.decode(base64.normalize(parts[1])));
      final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
      final exp = jsonMap['exp'] as int?;
      if (exp != null) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    } catch (e) {
      _log.warning('Failed to parse token expiration: $e');
    }
    return DateTime.now().add(const Duration(minutes: 2));
  }

  Future<void> _attemptSilentRefresh() async {
    if (_isRefreshing || _refreshToken == null) return;
    _isRefreshing = true;
    try {
      final res = await _authApiClient.refresh(_refreshToken!);
      switch (res) {
        case Ok<AuthResponse>():
          await _setAuthState(res.value);
          _log.fine('Silent refresh success');
          break;
        case Error<AuthResponse>():
          _log.warning('Silent refresh failed → logout');
          await logout();
      }
    } finally {
      _isRefreshing = false;
    }
  }

  // ────────────────────────── Stockage local ───────────────────────
  Future<void> _fetchFromStorage() async {
    // 1. jetons
    final (at, rt) = await _authStorageService.fetchTokens();
    _accessToken = at;
    _refreshToken = rt;
    _isAuthenticated = _accessToken != null;
    if (_accessToken != null) {
      _tokenExpiration = _parseTokenExpiration(_accessToken!);
    }

    // 2. user JSON
    final userJsonRes = await _authStorageService.fetchUserJson();
    if (userJsonRes is Ok<String?> && userJsonRes.value != null) {
      try {
        _currentUser = User.fromJson(
            jsonDecode(userJsonRes.value!) as Map<String, dynamic>);
      } catch (e) {
        await _authStorageService.saveUserJson(null);
      }
    }
  }

  // ────────────────────────── Provider header ──────────────────────
  String? _authHeaderProvider() {
    if (_accessToken == null) return null;
    // access expiré ?
    if (_tokenExpiration != null && DateTime.now().isAfter(_tokenExpiration!)) {
      _attemptSilentRefresh();
      // on laisse l'ancien token pour cette requête ; la suivante aura le nouveau
    }
    return 'Bearer $_accessToken';
  }

  // ────────────────────────── AuthRepository impl. ─────────────────
  @override
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) return _isAuthenticated!;
    await _fetchFromStorage();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final res = await _authApiClient.register(
        RegisterRequest(username: username, email: email, password: password),
      );
      return switch (res) {
        final Ok<AuthResponse> r =>
          _setAuthState(r.value).then((_) => const Result.ok(null)),
        final Error<AuthResponse> e => Result.error(e.error),
      };
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
      final res = await _authApiClient.login(
        LoginRequest(email: email, password: password),
      );
      return switch (res) {
        final Ok<AuthResponse> r =>
          _setAuthState(r.value).then((_) => const Result.ok(null)),
        final Error<AuthResponse> e => Result.error(e.error),
      };
    } finally {
      notifyListeners();
    }
  }

  Future<void> _setAuthState(AuthResponse auth) async {
    _isAuthenticated = true;
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
    _tokenExpiration = _parseTokenExpiration(auth.accessToken);

    _currentUser = User(
      id: auth.currentUser.id,
      username: auth.currentUser.username,
      email: auth.currentUser.email,
      description: auth.currentUser.description,
      isPremium: auth.currentUser.isPremium,
      photoUrl: auth.currentUser.photoUrl,
      birthDate: auth.currentUser.birthDate,
    );

    await _authStorageService.saveTokens(
      accessToken: _accessToken,
      refreshToken: _refreshToken,
    );
    await _authStorageService.saveUserJson(jsonEncode(_currentUser!.toJson()));
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Future<Result<void>> logout() async {
    try {
      if (_refreshToken != null) {
        await _authApiClient.logout(_refreshToken!);
      }
      await _authStorageService.saveTokens(
          accessToken: null, refreshToken: null);
      await _authStorageService.saveUserJson(null);
      _accessToken = _refreshToken = null;
      _currentUser = null;
      _tokenExpiration = null;
      _isAuthenticated = false;
      return const Result.ok(null);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    if (_currentUser != null) return Result.ok(_currentUser!);
    await _fetchFromStorage();
    return _currentUser != null
        ? Result.ok(_currentUser!)
        : Result.error(Exception('No current user'));
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _apiClient.changePassword(currentPassword, newPassword).then((res) {
      return switch (res) {
        Ok<void>() => const Result.ok(null),
        final Error<void> e => Result.error(e.error),
      };
    });
  }

  @override
  void updateCurrentUser(User user) {
    _currentUser = user;
    _authStorageService.saveUserJson(jsonEncode(user.toJson()));
    notifyListeners();
  }
}
