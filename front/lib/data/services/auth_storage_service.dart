import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

import '../../utils/result.dart';

class AuthStorageService {
  static const _atKey = 'ACCESS_TOKEN';
  static const _rtKey = 'REFRESH_TOKEN';
  static const _userJsonKey = 'USER_JSON';

  final _log = Logger('AuthStorageService');
  static const _secureStorage = FlutterSecureStorage();

  Future<(String?, String?)> fetchTokens() async {
    final at = await _secureStorage.read(key: _atKey);
    final rt = await _secureStorage.read(key: _rtKey);
    return (at, rt);
  }

  Future<void> saveTokens({
    required String? accessToken,
    required String? refreshToken,
  }) async {
    await _secureStorage.write(key: _atKey, value: accessToken);
    await _secureStorage.write(key: _rtKey, value: refreshToken);
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
