import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class PreferencesService {
  static const _darkModeKey = 'DARK_MODE';
  static const _notificationsKey = 'NOTIFICATIONS';
  final _log = Logger('PreferencesService');
  static const _secureStorage = FlutterSecureStorage();

  Future<bool> getDarkMode() async {
    try {
      final value = await _secureStorage.read(key: _darkModeKey);
      return value == 'true';
    } catch (e) {
      _log.warning('Failed to get dark mode preference', e);
      return false; // default value
    }
  }

  Future<void> setDarkMode(bool value) async {
    try {
      await _secureStorage.write(key: _darkModeKey, value: value.toString());
    } catch (e) {
      _log.warning('Failed to set dark mode preference', e);
    }
  }

  Future<bool> getNotifications() async {
    try {
      final value = await _secureStorage.read(key: _notificationsKey);
      return value != 'false'; // default to true
    } catch (e) {
      _log.warning('Failed to get notifications preference', e);
      return true; // default value
    }
  }

  Future<void> setNotifications(bool value) async {
    try {
      await _secureStorage.write(
          key: _notificationsKey, value: value.toString());
    } catch (e) {
      _log.warning('Failed to set notifications preference', e);
    }
  }
}
