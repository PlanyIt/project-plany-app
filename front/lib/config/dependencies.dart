import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/category/category_repository.dart';
import '../data/repositories/category/category_repository_remote.dart';
import '../data/repositories/comment/comment_repository.dart';
import '../data/repositories/comment/comment_repository_remote.dart';
import '../data/repositories/plan/plan_repository.dart';
import '../data/repositories/plan/plan_repository_remote.dart';
import '../data/repositories/step/step_repository.dart';
import '../data/repositories/step/step_repository_remote.dart';
import '../data/repositories/user/user_repository.dart';
import '../data/repositories/user/user_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/api/auth_api_client.dart';
import '../data/services/auth_storage_service.dart';
import '../data/services/imgur_service.dart';
import '../data/services/location_service.dart';
import '../data/services/session_manager.dart';

List<SingleChildWidget> get providers {
  final apiHost = dotenv.env['API_HOST'] ?? 'localhost';

  return [
    Provider(
      create: (context) => AuthApiClient(host: apiHost),
    ),
    Provider(
      create: (context) => ApiClient(host: apiHost),
    ),
    Provider(create: (_) => ImgurService()),
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => AuthStorageService()),
    ChangeNotifierProvider<AuthRepository>(
      create: (context) => AuthRepositoryRemote(
        authApiClient: context.read(),
        apiClient: context.read(),
        authStorageService: context.read(),
      ),
    ),
    Provider<CategoryRepository>(
      create: (context) => CategoryRepositoryRemote(
        apiClient: context.read(),
      ),
    ),
    Provider<PlanRepository>(
      create: (context) => PlanRepositoryRemote(
        apiClient: context.read(),
      ),
    ),
    Provider<StepRepository>(
      create: (context) => StepRepositoryRemote(
        apiClient: context.read(),
        imgurService: context.read(),
      ),
    ),
    Provider<CommentRepository>(
      create: (context) => CommentRepositoryRemote(
        apiClient: context.read(),
        imgurService: context.read(),
      ),
    ),
    Provider<UserRepository>(
      create: (context) => UserRepositoryRemote(
        apiClient: context.read(),
        imgurService: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => SessionManager(
        authRepository: context.read(),
        planRepository: context.read(),
        categoryRepository: context.read(),
        stepRepository: context.read(),
        commentRepository: context.read(),
        userRepository: context.read(),
      ),
    ),
  ];
}
