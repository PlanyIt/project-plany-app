import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:logging/logging.dart';

class SignupViewModel {
  SignupViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    register = Command1<
        void,
        (
          String email,
          String username,
          String description,
          String password
        )>(_register);
  }

  final AuthRepository _authRepository;
  final _log = Logger('SignupViewModel');

  late Command1 register;

  Future<Result<void>> _register(
      (String, String, String, String) credentials) async {
    print("Registering with credentials: $credentials");
    final (email, username, description, password) = credentials;
    final result = await _authRepository.register(
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
