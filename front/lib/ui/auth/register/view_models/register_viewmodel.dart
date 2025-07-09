import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/services/session_manager.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';
import '../../../../utils/validation_utils.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required SessionManager sessionManager})
      : _sessionManager = sessionManager {
    register = Command1<void, (String email, String username, String password)>(
        _register);
  }

  final SessionManager _sessionManager;
  final _log = Logger('RegisterViewModel');

  late Command1 register;

  String? _errorMessage;
  bool _obscurePassword = true;

  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? validateCredentials(String email, String username, String password) {
    return ValidationUtils.validateRegisterCredentials(
        email, username, password);
  }

  Future<Result<void>> _register((String, String, String) credentials) async {
    final (email, username, password) = credentials;

    final validationError = validateCredentials(email, username, password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return Result.error(Exception(validationError));
    }

    clearError();

    final result = await _sessionManager.register(
      email: email.trim(),
      username: username.trim(),
      password: password,
    );

    if (result is Error<void>) {
      _log.warning('register failed! ${result.error}');
      _errorMessage = 'Échec de l\'inscription. Vérifiez vos informations.';
      notifyListeners();
    }

    return result;
  }
}
