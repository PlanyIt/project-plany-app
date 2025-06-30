import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/repositories/auth/auth_repository_remote.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/categorie/category_repository_remote.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/step/step_repository_remote.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/data/repositories/comment/comment_repository_remote.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/core/session/session_manager.dart';

// =========================================================================
// SERVICES CORE
// =========================================================================

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authStorageServiceProvider = Provider<AuthStorageService>((ref) {
  return AuthStorageService();
});

final imgurServiceProvider = Provider<ImgurService>((ref) {
  return ImgurService();
});

// =========================================================================
// REPOSITORIES
// =========================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
    authApiClient: ref.read(authApiClientProvider),
    authStorageService: ref.read(authStorageServiceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
  );
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
  );
});

final stepRepositoryProvider = Provider<StepRepository>((ref) {
  return StepRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
    imgurService: ref.read(imgurServiceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
    authStorageService: ref.read(authStorageServiceProvider),
  );
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryRemote(
    apiClient: ref.read(apiClientProvider),
  );
});

// =========================================================================
// APPLICATION SERVICES
// =========================================================================

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    authRepository: ref.read(authRepositoryProvider),
    planRepository: ref.read(planRepositoryProvider) as PlanRepositoryRemote,
    categoryRepository:
        ref.read(categoryRepositoryProvider) as CategoryRepositoryRemote,
    stepRepository: ref.read(stepRepositoryProvider) as StepRepositoryRemote,
    userRepository: ref.read(userRepositoryProvider) as UserRepositoryRemote,
    commentRepository:
        ref.read(commentRepositoryProvider) as CommentRepositoryRemote,
  );
});
