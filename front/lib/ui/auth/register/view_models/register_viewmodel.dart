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

  final ValueNotifier<String?> snackbarMessage = ValueNotifier(null);
  final ValueNotifier<String?> passwordErrorMessage = ValueNotifier(null);

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearSnackbar() {
    snackbarMessage.value = null;
    passwordErrorMessage.value = null;
  }

  String? validateCredentials(String email, String username, String password) {
    final error =
        ValidationUtils.validateRegisterCredentials(email, username, password);
    passwordErrorMessage.value = null;

    if (error != null && error.toLowerCase().contains('mot de passe')) {
      passwordErrorMessage.value = error;
    }

    return error;
  }

  Future<Result<void>> _register((String, String, String) credentials) async {
    final (email, username, password) = credentials;

    final validationError = validateCredentials(email, username, password);
    if (validationError != null) {
      snackbarMessage.value = validationError;
      return Result.error(Exception(validationError));
    }

    final result = await _sessionManager.register(
      email: email.trim(),
      username: username.trim(),
      password: password,
    );

    if (result is Error<void>) {
      _log.warning('Register failed! ${result.error}');
      snackbarMessage.value =
          'Échec de l\'inscription. Vérifiez vos informations.';
    }

    return result;
  }
}
