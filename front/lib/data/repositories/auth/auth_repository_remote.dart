import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/api/model/login_request/login_request_api_model.dart';
import 'package:front/data/services/api/model/login_response/login_response_api_model.dart';
import 'package:front/data/services/api/model/register_request/register_request_api_model.dart';
import 'package:front/data/services/api/model/register_response/register_response_api_model.dart';
import 'package:front/data/services/api/model/refresh_token_request/refresh_token_request_api_model.dart';
import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/utils/result.dart';
import 'package:front/utils/exceptions.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';

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
  String? _authToken;
  String? _refreshToken;
  final _log = Logger('AuthRepositoryRemote');

  /// Fetch token from shared preferences
  Future<void> _fetch() async {
    final result = await _authStorageService.fetchToken();
    switch (result) {
      case Ok<String?>():
        _authToken = result.value;
      case Error<String?>():
        _log.severe(
          'Failed to fetch Token from SharedPreferences',
          result.error,
        );
    }
  }

  /// Fetch refresh token from shared preferences
  Future<void> _fetchRefreshToken() async {
    final result = await _authStorageService.fetchRefreshToken();
    switch (result) {
      case Ok<String?>():
        _refreshToken = result.value;
      case Error<String?>():
        _log.severe(
          'Failed to fetch Refresh Token from SharedPreferences',
          result.error,
        );
    }
  }

  bool _isTokenExpired() {
    if (_authToken == null) return true;
    return JwtDecoder.isExpired(_authToken!);
  }

  /// Try to refresh token if expired
  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final refreshResult = await _authApiClient.refreshToken(
        RefreshTokenRequestApiModel(refreshToken: _refreshToken!),
      );

      switch (refreshResult) {
        case Ok():
          _authToken = refreshResult.value.accessToken;
          _refreshToken = refreshResult.value.refreshToken;
          await _authStorageService.saveToken(refreshResult.value.accessToken);
          await _authStorageService
              .saveRefreshToken(refreshResult.value.refreshToken);

          return true;
        case Error():
          _log.warning('Failed to refresh token: ${refreshResult.error}');
          return false;
      }
    } catch (e) {
      _log.warning('Error during token refresh: $e');
      return false;
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    await _fetch(); // Toujours récupérer les dernières données
    await _fetchRefreshToken(); // Récupérer aussi le refresh token

    if (_authToken == null) return false;

    // Si le token est expiré, essayer de le rafraîchir
    if (_isTokenExpired()) {
      final refreshSuccess = await _tryRefreshToken();
      return refreshSuccess;
    }

    return true;
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _log.warning('Login attempted with empty credentials');
        return Result.error(
          const ValidationException('Email et mot de passe sont requis'),
        );
      }

      if (!_isValidEmail(email)) {
        _log.warning('Login attempted with invalid email format: $email');
        return Result.error(
          const ValidationException('Format d\'email invalide'),
        );
      }

      final result = await _authApiClient.login(
        LoginRequestApiModel(email: email, password: password),
      );

      switch (result) {
        case Ok<LoginResponseApiModel>():
          _log.info('User logged in successfully');

          // Use accessToken if available, otherwise fall back to token
          final token = result.value.accessToken ?? result.value.token;
          final refreshToken = result.value.refreshToken;

          if (token == null || token.isEmpty) {
            _log.severe('No valid token received from login response');
            return Result.error(
              const AuthenticationException('Token invalide reçu du serveur'),
            );
          }

          // Validate token format
          if (!_isValidJWT(token)) {
            _log.severe('Invalid JWT token format received');
            return Result.error(
              const AuthenticationException('Format de token invalide'),
            );
          }

          _authToken = token;
          _refreshToken = refreshToken;

          // Save tokens with error handling
          final tokenSaveResult = await _authStorageService.saveToken(token);
          if (tokenSaveResult is Error) {
            _log.severe('Failed to save auth token');
            return Result.error(
              const StorageException('Erreur lors de la sauvegarde du token'),
            );
          }

          if (refreshToken != null) {
            final refreshSaveResult =
                await _authStorageService.saveRefreshToken(refreshToken);
            if (refreshSaveResult is Error) {
              _log.warning('Failed to save refresh token');
            }
          }
          if (result.value.userId.isNotEmpty) {
            final userIdSaveResult =
                await _authStorageService.saveUserId(result.value.userId);
            if (userIdSaveResult is Error) {
              _log.warning('Failed to save user ID');
            }
          }

          _apiClient.authHeaderProvider = _authHeaderProvider;
          return const Result.ok(null);

        case Error<LoginResponseApiModel>():
          _log.warning('Login failed: ${result.error}');

          // Handle specific error types
          if (result.error is NetworkException) {
            return Result.error(
              const NetworkException('Problème de connexion réseau'),
            );
          } else if (result.error is ApiException) {
            final apiError = result.error as ApiException;
            if (apiError.statusCode == 401) {
              return Result.error(
                const AuthenticationException(
                    'Email ou mot de passe incorrect'),
              );
            } else if (apiError.statusCode == 429) {
              return Result.error(
                const RateLimitException(
                    'Trop de tentatives, réessayez plus tard'),
              );
            }
          }

          return Result.error(result.error);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error during login', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur inattendue lors de la connexion'),
      );
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> logout() async {
    _log.info('User logged out');
    try {
      final result = await _authStorageService.saveToken(null);
      await _authStorageService.saveRefreshToken(null);
      await _authStorageService.saveUserId(null);

      if (result is Error<void>) {
        _log.severe('Failed to clear stored auth token');
      }

      _authToken = null;
      _refreshToken = null;

      return result;
    } finally {
      notifyListeners();
    }
  }

  String? _authHeaderProvider() {
    if (_authToken == null) {
      _log.warning('Auth header requested but token is null');
      return null;
    }
    return 'Bearer $_authToken';
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String description,
    required String password,
  }) async {
    try {
      final result = await _authApiClient.register(
        RegisterRequestApiModel(
          email: email,
          username: username,
          description: description,
          password: password,
        ),
      );
      switch (result) {
        case Ok<RegisterResponseApiModel>():
          _log.info('User registered successfully');
          return await login(email: email, password: password);

        case Error<RegisterResponseApiModel>():
          _log.warning('Error registering user: ${result.error}');
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validates JWT token format
  bool _isValidJWT(String token) {
    final parts = token.split('.');
    return parts.length == 3;
  }
}
