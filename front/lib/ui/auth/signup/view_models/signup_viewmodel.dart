import 'package:front/application/session_manager.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class SignupViewModel {
  SignupViewModel({required SessionManager sessionManager})
      : _sessionManager = sessionManager {
    register = Command1<
        void,
        (
          String email,
          String username,
          String description,
          String password
        )>(_register);
  }

  final SessionManager _sessionManager;
  final _log = Logger('SignupViewModel');

  late Command1 register;

  Future<Result<void>> _register(
      (String, String, String, String) credentials) async {
    final (email, username, description, password) = credentials;
    final result = await _sessionManager.register(
      email: email,
      username: username,
      description: description,
      password: password,
    );
    if (result is Error<void>) {
      _log.warning('register failed! ${result.error}');
    }
    return result;
  }
}
