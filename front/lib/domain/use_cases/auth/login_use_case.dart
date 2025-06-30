import 'package:logging/logging.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/result.dart';

/// UseCase for logging in a user.
class LoginUseCase {
  LoginUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final _log = Logger('LoginUseCase');

  /// Attempts to log in with the provided [email] and [password].
  /// Returns [Result.ok] on success, or [Result.error] on failure.
  Future<Result<void>> execute({
    required String email,
    required String password,
  }) async {
    _log.fine('Attempting login for email: $email');
    final result =
        await _authRepository.login(email: email, password: password);
    switch (result) {
      case Ok<void>():
        _log.fine('Login successful for $email');
        return const Result.ok(null);
      case Error<void>():
        _log.warning('Login failed for $email: \\${result.error}');
        return Result.error(result.error);
    }
  }
}
