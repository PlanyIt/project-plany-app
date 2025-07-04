import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

import '../../utils/result.dart';

class AuthStorageService {
  static const _tokenKey = 'TOKEN';
  static const _userJsonKey = 'USER_JSON';

  final _log = Logger('AuthStorageService');
  static const _secureStorage = FlutterSecureStorage();

  /// --- TOKEN ---
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
        _log.finer('Saved token');
        await _secureStorage.write(key: _tokenKey, value: token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Result.error(e);
    }
  }

  /// --- USER JSON (profil complet) ---
  Future<Result<String?>> fetchUserJson() async {
    try {
      final json = await _secureStorage.read(key: _userJsonKey);
      _log.finer('Got user JSON from SecureStorage');
      return Result.ok(json);
    } on Exception catch (e) {
      _log.warning('Failed to get user JSON', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveUserJson(String? userJson) async {
    try {
      if (userJson == null) {
        _log.finer('Removed user JSON');
        await _secureStorage.delete(key: _userJsonKey);
      } else {
        _log.finer('Saved user JSON');
        await _secureStorage.write(key: _userJsonKey, value: userJson);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set user JSON', e);
      return Result.error(e);
    }
  }
}
