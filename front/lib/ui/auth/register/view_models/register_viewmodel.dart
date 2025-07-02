import 'package:logging/logging.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../utils/command.dart';
import '../../../../utils/result.dart';

class RegisterViewModel {
  RegisterViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    register = Command1<void, (String email, String username, String password)>(
        _register);
  }

  final AuthRepository _authRepository;
  final _log = Logger('RegisterViewModel');

  late Command1 register;

  Future<Result<void>> _register((String, String, String) credentials) async {
    final (email, username, password) = credentials;
    final result = await _authRepository.register(
      email: email,
      username: username,
      password: password,
    );
    if (result is Error<void>) {
      _log.warning('register failed! ${result.error}');
    }
    return result;
  }
}
