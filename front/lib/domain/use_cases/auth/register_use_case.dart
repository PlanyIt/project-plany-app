import 'package:logging/logging.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/result.dart';

/// UseCase for registering a user.
class RegisterUseCase {
  RegisterUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final _log = Logger('RegisterUseCase');

  /// Attempts to register a user with the provided details.
  /// Returns [Result.ok] on success, or [Result.error] on failure.
  Future<Result<void>> execute({
    required String email,
    required String username,
    required String description,
    required String password,
  }) async {
    _log.fine('Attempting register for email: $email');
    final result = await _authRepository.register(
      email: email,
      username: username,
      description: description,
      password: password,
    );
    switch (result) {
      case Ok<void>():
        _log.fine('Register successful for $email');
        return const Result.ok(null);
      case Error<void>():
        _log.warning('Register failed for $email: \\${result.error}');
        return Result.error(result.error);
    }
  }
}
