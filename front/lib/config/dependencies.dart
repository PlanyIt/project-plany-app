import 'package:front/application/session_manager.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/repositories/auth/auth_repository_remote.dart';
import 'package:front/data/repositories/categorie/category_repository_remote.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/data/repositories/comment/comment_repository_remote.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:front/data/repositories/step/step_repository_remote.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/data/services/auth_storage_service.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:front/ui/auth/signup/view_models/signup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Configure dependencies for the new unified state management
List<SingleChildWidget> get unifiedProviders {
  return [
    // Core Services
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => ImgurService()),
    Provider(create: (context) => AuthStorageService()), // Repositories
    ChangeNotifierProxyProvider3<AuthStorageService, AuthApiClient, ApiClient,
        AuthRepository>(
      create: (context) => AuthRepositoryRemote(
        authStorageService: context.read<AuthStorageService>(),
        authApiClient: context.read<AuthApiClient>(),
        apiClient: context.read<ApiClient>(),
      ),
      update: (context, authStorage, authApiClient, apiClient, previous) =>
          previous ??
          AuthRepositoryRemote(
            authStorageService: authStorage,
            authApiClient: authApiClient,
            apiClient: apiClient,
          ),
    ),
    ProxyProvider<ApiClient, CategoryRepositoryRemote>(
      update: (context, apiClient, _) => CategoryRepositoryRemote(
        apiClient: apiClient,
      ),
    ),
    ProxyProvider<ApiClient, PlanRepositoryRemote>(
      update: (context, apiClient, _) => PlanRepositoryRemote(
        apiClient: apiClient,
      ),
    ),
    ProxyProvider2<ApiClient, ImgurService, StepRepositoryRemote>(
      update: (context, apiClient, imgurService, _) => StepRepositoryRemote(
        apiClient: apiClient,
        imgurService: imgurService,
      ),
    ),
    ProxyProvider2<ApiClient, AuthStorageService, UserRepositoryRemote>(
      update: (context, apiClient, authStorage, _) => UserRepositoryRemote(
        apiClient: apiClient,
        authStorageService: authStorage,
      ),
    ),
    ProxyProvider<ApiClient, CommentRepository>(
      update: (context, apiClient, _) => CommentRepositoryRemote(
        apiClient: apiClient,
      ),
    ),

    // Session Manager
    ProxyProvider6<
        AuthRepository,
        PlanRepositoryRemote,
        CategoryRepositoryRemote,
        StepRepositoryRemote,
        UserRepositoryRemote,
        CommentRepository,
        SessionManager>(
      update: (context, authRepo, planRepo, categoryRepo, stepRepo, userRepo,
              commentRepo, _) =>
          SessionManager(
        authRepository: authRepo,
        planRepository: planRepo,
        categoryRepository: categoryRepo,
        stepRepository: stepRepo,
        userRepository: userRepo,
        commentRepository: commentRepo,
      ),
    ), // ViewModels with unified state management
    ChangeNotifierProxyProvider5<
        CategoryRepositoryRemote,
        PlanRepositoryRemote,
        UserRepositoryRemote,
        StepRepositoryRemote,
        SessionManager,
        DashboardViewModel>(
      create: (context) => DashboardViewModel(
        categoryRepository: context.read<CategoryRepositoryRemote>(),
        planRepository: context.read<PlanRepositoryRemote>(),
        userRepository: context.read<UserRepositoryRemote>(),
        stepRepository: context.read<StepRepositoryRemote>(),
        sessionManager: context.read<SessionManager>(),
      ),
      update: (context, categoryRepo, planRepo, userRepo, stepRepo,
              sessionManager, previous) =>
          previous ??
          DashboardViewModel(
            categoryRepository: categoryRepo,
            planRepository: planRepo,
            userRepository: userRepo,
            stepRepository: stepRepo,
            sessionManager: sessionManager,
          ),
    ),

    ProxyProvider<SessionManager, LoginViewModel>(
      update: (context, sessionManager, _) => LoginViewModel(
        sessionManager: sessionManager,
      ),
    ),

    ProxyProvider<SessionManager, SignupViewModel>(
      update: (context, sessionManager, _) => SignupViewModel(
        sessionManager: sessionManager,
      ),
    ),
  ];
}
