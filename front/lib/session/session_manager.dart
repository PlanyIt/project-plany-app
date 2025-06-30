import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/repositories/categorie/category_repository_remote.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/data/repositories/step/step_repository_remote.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:front/utils/result.dart';

/// Gère les actions transversales comme login/logout,
/// et vide les caches si nécessaire.
class SessionManager {
  SessionManager({
    required AuthRepository authRepository,
    required PlanRepositoryRemote planRepository,
    required CategoryRepositoryRemote categoryRepository,
    required StepRepositoryRemote stepRepository,
    required UserRepositoryRemote userRepository,
    required CommentRepository commentRepository,
  })  : _authRepository = authRepository,
        _planRepository = planRepository,
        _categoryRepository = categoryRepository,
        _stepRepository = stepRepository,
        _userRepository = userRepository,
        _commentRepository = commentRepository;

  final AuthRepository _authRepository;
  final PlanRepositoryRemote _planRepository;
  final CategoryRepositoryRemote _categoryRepository;
  final StepRepositoryRemote _stepRepository;
  final UserRepositoryRemote _userRepository;
  final CommentRepository _commentRepository;

  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result is Ok) {
      _clearAllCaches();
    }

    return result;
  }

  Future<Result<void>> logout() async {
    final result = await _authRepository.logout();

    if (result is Ok) {
      _clearAllCaches();
    }

    return result;
  }

  Future<Result<void>> register({
    required String email,
    required String username,
    required String description,
    required String password,
  }) async {
    final result = await _authRepository.register(
      email: email,
      username: username,
      description: description,
      password: password,
    );

    if (result is Ok) {
      _clearAllCaches();
    }

    return result;
  }

  void resetSession() {
    _clearAllCaches();
  }

  void _clearAllCaches() {
    _planRepository.clearCache();
    _categoryRepository.clearCache();
    _stepRepository.clearCache();
    _userRepository.clearUserCache();
    // Note: CommentRepository doesn't have a cache to clear currently
    // but we keep the reference for future use
  }
}
