import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class AuthStorageService {
  static const _tokenKey = 'TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userIdKey = 'USER_ID';
  final _log = Logger('AuthStorageService');
  // Use secure storage for all data
  static const _secureStorage = FlutterSecureStorage();
  Future<Result<String?>> fetchToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      _log.finer('Got token from SecureStorage');
      return Result.ok(token);
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveToken(String? token) async {
    try {
      if (token == null) {
        _log.finer('Removed token');
        await _secureStorage.delete(key: _tokenKey);
      } else {
        _log.finer('Replaced token');
        await _secureStorage.write(key: _tokenKey, value: token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchRefreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      _log.finer('Got refresh token from SecureStorage');
      return Result.ok(refreshToken);
    } on Exception catch (e) {
      _log.warning('Failed to get refresh token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveRefreshToken(String? refreshToken) async {
    try {
      if (refreshToken == null) {
        _log.finer('Removed refresh token');
        await _secureStorage.delete(key: _refreshTokenKey);
      } else {
        _log.finer('Replaced refresh token');
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set refresh token', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchUserId() async {
    try {
      final userId = await _secureStorage.read(key: _userIdKey);
      _log.finer('Got user ID from SecureStorage');
      return Result.ok(userId);
    } on Exception catch (e) {
      _log.warning('Failed to get user ID', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveUserId(String? userId) async {
    try {
      if (userId == null) {
        _log.finer('Removed user ID');
        await _secureStorage.delete(key: _userIdKey);
      } else {
        _log.finer('Replaced user ID');
        await _secureStorage.write(key: _userIdKey, value: userId);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set user ID', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> clear() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();
      _log.finer('Cleared all SecureStorage');

      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to clear storage', e);
      return Result.error(e);
    }
  }
}
