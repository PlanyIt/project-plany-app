import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/repositories/categorie/category_repository_remote.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/data/repositories/user/user_repository_remote.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/api/auth_api_client.dart';
import '../data/services/shared_preferences_service.dart';

/// Shared providers for all configurations.
List<SingleChildWidget> _sharedProviders = [];

/// Configure dependencies for remote data.
/// This dependency list uses repositories that connect to a remote server.
List<SingleChildWidget> get providersRemote {
  return [
    Provider(create: (context) => AuthApiClient()),
    Provider(create: (context) => ApiClient()),
    Provider(create: (context) => SharedPreferencesService()),
    ChangeNotifierProvider(
      create: (context) => AuthRepositoryRemote(
        authApiClient: context.read(),
        apiClient: context.read(),
        sharedPreferencesService: context.read(),
      ) as AuthRepository,
    ),
    Provider(
      create: (context) => CategoryRepositoryRemote(
        apiClient: context.read(),
      ) as CategoryRepository,
    ),
    Provider(
      create: (context) =>
          UserRepositoryRemote(apiClient: context.read()) as UserRepository,
    ),
    Provider(
      create: (context) => PlanRepositoryRemote(
        apiClient: context.read(),
      ) as PlanRepository,
    ),
    ..._sharedProviders,
  ];
}
