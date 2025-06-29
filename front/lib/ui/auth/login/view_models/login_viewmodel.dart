import 'package:front/application/session_manager.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class LoginViewModel {
  LoginViewModel({required SessionManager sessionManager})
      : _sessionManager = sessionManager {
    login = Command1<void, (String email, String password)>(_login);
  }

  final SessionManager _sessionManager;
  final _log = Logger('LoginViewModel');

  late Command1<void, (String, String)> login;

  Future<Result<void>> _login((String, String) credentials) async {
    final (email, password) = credentials;

    final result = await _sessionManager.login(
      email: email,
      password: password,
    );

    if (result is Error<void>) {
      _log.warning('Login failed! ${result.error}');
    }

    return result;
  }
}
