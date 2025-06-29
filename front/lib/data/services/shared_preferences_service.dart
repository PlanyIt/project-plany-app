import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _userIdKey = 'USER_ID';
  final _log = Logger('SharedPreferencesService');

  Future<Result<String?>> fetchToken() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got token from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_tokenKey));
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveToken(String? token) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (token == null) {
        _log.finer('Removed token');
        await sharedPreferences.remove(_tokenKey);
      } else {
        _log.finer('Replaced token');
        await sharedPreferences.setString(_tokenKey, token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchRefreshToken() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got refresh token from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_refreshTokenKey));
    } on Exception catch (e) {
      _log.warning('Failed to get refresh token', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveRefreshToken(String? refreshToken) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (refreshToken == null) {
        _log.finer('Removed refresh token');
        await sharedPreferences.remove(_refreshTokenKey);
      } else {
        _log.finer('Replaced refresh token');
        await sharedPreferences.setString(_refreshTokenKey, refreshToken);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set refresh token', e);
      return Result.error(e);
    }
  }

  Future<Result<String?>> fetchUserId() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got user ID from SharedPreferences');
      return Result.ok(sharedPreferences.getString(_userIdKey));
    } on Exception catch (e) {
      _log.warning('Failed to get user ID', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> saveUserId(String? userId) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (userId == null) {
        _log.finer('Removed user ID');
        await sharedPreferences.remove(_userIdKey);
      } else {
        _log.finer('Replaced user ID');
        await sharedPreferences.setString(_userIdKey, userId);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to set user ID', e);
      return Result.error(e);
    }
  }

  Future<Result<void>> clear() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Cleared all SharedPreferences');
      await sharedPreferences.clear();
      return const Result.ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to clear SharedPreferences', e);
      return Result.error(e);
    }
  }
}
