import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/category/category_repository.dart';
import '../data/repositories/category/category_repository_remote.dart';
import '../data/repositories/plan/plan_repository.dart';
import '../data/repositories/plan/plan_repository_remote.dart';
import '../data/repositories/step/step_repository.dart';
import '../data/repositories/step/step_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/api/auth_api_client.dart';
import '../data/services/auth_storage_service.dart';
import '../data/services/imgur_service.dart';
import '../data/services/session_manager.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(
        create: (context) => AuthApiClient(
              host: dotenv.env['API_HOST'],
              port: int.parse(dotenv.env['API_PORT'] ?? '3000'),
            )),
    Provider(
        create: (context) => ApiClient(
              host: dotenv.env['API_HOST'],
              port: int.parse(dotenv.env['API_PORT'] ?? '3000'),
            )),
    Provider(create: (context) => ImgurService()),
    Provider(create: (context) => AuthStorageService()),
    ChangeNotifierProvider<AuthRepository>(
      create: (context) => AuthRepositoryRemote(
        authApiClient: context.read(),
        apiClient: context.read(),
        authStorageService: context.read(),
      ) as AuthRepository,
    ),
    Provider(
      create: (context) => CategoryRepositoryRemote(apiClient: context.read())
          as CategoryRepository,
    ),
    Provider(
      create: (context) =>
          PlanRepositoryRemote(apiClient: context.read()) as PlanRepository,
    ),
    Provider(
      create: (context) => StepRepositoryRemote(
        apiClient: context.read(),
        imgurService: context.read(),
      ) as StepRepository,
    ),
    Provider(
      create: (context) => SessionManager(
        authRepository: context.read(),
        planRepository: context.read(),
        categoryRepository: context.read(),
        stepRepository: context.read(),
      ),
    ),
  ];
}
