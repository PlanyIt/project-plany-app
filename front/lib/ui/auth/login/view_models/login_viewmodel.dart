import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/services/session_manager.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';
import '../../../../utils/validation_utils.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required SessionManager sessionManager})
      : _sessionManager = sessionManager {
    login = Command1<void, (String email, String password)>(_login);
  }

  final SessionManager _sessionManager;
  final _log = Logger('LoginViewModel');

  late Command1 login;

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

  String? validateCredentials(String email, String password) {
    return ValidationUtils.validateLoginCredentials(email, password);
  }

  Future<Result<void>> _login((String, String) credentials) async {
    final (email, password) = credentials;

    final validationError = validateCredentials(email, password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return Result.error(Exception(validationError));
    }

    clearError();

    final result = await _sessionManager.login(
      email: email.trim(),
      password: password,
    );

    if (result is Error<void>) {
      _log.warning('Login failed! ${result.error}');
      _errorMessage = 'Échec de la connexion. Vérifiez vos identifiants.';
      notifyListeners();
    }

    return result;
  }
}
