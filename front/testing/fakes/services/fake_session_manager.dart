import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/services/session_manager.dart';
import 'package:front/utils/result.dart';

import '../repositories/fake_auth_repository.dart';

class FakeSessionManager extends SessionManager {
  final FakeAuthRepository fakeAuthRepository;

  FakeSessionManager({
    required FakeAuthRepository authRepository,
    required super.planRepository,
    required super.categoryRepository,
    required super.stepRepository,
  })  : fakeAuthRepository = authRepository,
        super(authRepository: authRepository);

  bool isCleared = false;
  bool loggedIn = false;

  AuthRepository get exposedAuthRepository => fakeAuthRepository;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    final result =
        await fakeAuthRepository.login(email: email, password: password);
    loggedIn = fakeAuthRepository.token != null;
    return result;
  }

  @override
  Future<Result<void>> logout() async {
    fakeAuthRepository.token = null;
    loggedIn = false;
    isCleared = true;
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    fakeAuthRepository.token = 'fake_token';
    loggedIn = true;
    return Result.ok(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    return loggedIn;
  }

  @override
  Future<void> resetSession() async {
    isCleared = true;
  }

  @override
  Future<bool> checkAuthAndCleanIfNeeded() async {
    return loggedIn;
  }

  @override
  Future<void> clearSpecificCaches({
    bool plans = false,
    bool categories = false,
    bool steps = false,
    bool users = false,
  }) async {
    isCleared = true;
  }
}
