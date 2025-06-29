import 'package:front/application/session_manager.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/repositories/auth/auth_repository_remote.dart';
import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/categorie/category_repository_remote.dart';
import 'package:front/data/repositories/comment/comment_repository.dart';
import 'package:front/data/repositories/comment/comment_repository_remote.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/repositories/step/step_repository_remote.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/api/auth_api_client.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/data/services/shared_preferences_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Shared providers for all configurations.
List<SingleChildWidget> _sharedProviders = [];

/// Configure dependencies for remote data.
List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => ImgurService()),
    Provider(
        create: (context) => SharedPreferencesService()), // Auth Repository
    ChangeNotifierProvider<AuthRepository>(
      create: (context) => AuthRepositoryRemote(
        authApiClient: context.read(),
        apiClient: context.read(),
        sharedPreferencesService: context.read(),
      ),
    ),

    // Category Repository
    Provider<CategoryRepositoryRemote>(
      create: (context) => CategoryRepositoryRemote(
        apiClient: context.read(),
      ),
    ),
    Provider<CategoryRepository>(
      create: (context) => context.read<CategoryRepositoryRemote>(),
    ),

    // User Repository
    Provider<UserRepositoryRemote>(
      create: (context) => UserRepositoryRemote(
        apiClient: context.read(),
        sharedPreferencesService: context.read(),
      ),
    ),
    Provider<UserRepository>(
      create: (context) => context.read<UserRepositoryRemote>(),
    ),

    // Plan Repository
    Provider<PlanRepositoryRemote>(
      create: (context) => PlanRepositoryRemote(apiClient: context.read()),
    ),
    Provider<PlanRepository>(
      create: (context) => context.read<PlanRepositoryRemote>(),
    ),

    // Step Repository
    Provider<StepRepositoryRemote>(
      create: (context) => StepRepositoryRemote(
        apiClient: context.read(),
        imgurService: context.read(),
      ),
    ),
    Provider<StepRepository>(
      create: (context) => context.read<StepRepositoryRemote>(),
    ), // Comment Repository
    Provider<CommentRepositoryRemote>(
      create: (context) => CommentRepositoryRemote(
        apiClient: context.read(),
      ),
    ),
    Provider<CommentRepository>(
      create: (context) => context.read<CommentRepositoryRemote>(),
    ),

    // ✅ SessionManager avec tous les repos concrets nécessaires
    Provider(
      create: (context) => SessionManager(
        authRepository: context.read<AuthRepository>(),
        planRepository: context.read<PlanRepositoryRemote>(),
        categoryRepository: context.read<CategoryRepositoryRemote>(),
        stepRepository: context.read<StepRepositoryRemote>(),
        userRepository: context.read<UserRepositoryRemote>(),
        commentRepository: context.read<CommentRepositoryRemote>(),
      ),
    ),

    ..._sharedProviders,
  ];
}
