import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../ui/auth/login/login_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/register/register_screen.dart';
import '../ui/auth/register/view_models/register_viewmodel.dart';
import '../ui/auth/reset-password/reset_password_screen.dart';
import '../ui/create_plan/create_plan_screen.dart';
import '../ui/create_plan/view_models/create_plan_view_model.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/dashboard/view_models/dashboard_viewmodel.dart';
import '../ui/detail_plan/plan_details_screen.dart';
import '../ui/detail_plan/view_models/detail/favorite_viewmodel.dart';
import '../ui/detail_plan/view_models/detail/follow_user_viewmodel.dart';
import '../ui/detail_plan/view_models/detail/plan_details_viewmodel.dart';
import '../ui/home/home_screen.dart';
import '../ui/profil/profile_screen.dart';
import '../ui/profil/view_models/profile_viewmodel.dart';
import '../ui/search_plan/search_screen.dart';
import '../ui/search_plan/view_models/search_view_model.dart';
import 'routes.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.dashboard,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: authRepository,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => LoginScreen(
            viewModel: LoginViewModel(sessionManager: context.read()),
          ),
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) => RegisterScreen(
            viewModel: RegisterViewModel(sessionManager: context.read()),
          ),
        ),
        GoRoute(
          path: Routes.reset,
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => DashboardScreen(
            viewModel: DashboardViewModel(
              categoryRepository: context.read(),
              authRepository: context.read(),
              planRepository: context.read(),
              locationService: context.read(),
            ),
          ),
          routes: [
            GoRoute(
              name: 'search',
              path: 'search',
              builder: (context, state) {
                final initialQuery = state.uri.queryParameters['query'];
                final initialCategory = state.uri.queryParameters['category'];

                return SearchScreen(
                  viewModel: SearchViewModel(
                    planRepository: context.read(),
                    categoryRepository: context.read(),
                  ),
                  initialQuery: initialQuery,
                  initialCategory: initialCategory,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.createPlan,
          builder: (context, state) => CreatePlanScreen(
            viewModel: CreatePlanViewModel(
              authRepository: context.read(),
              categoryRepository: context.read(),
              planRepository: context.read(),
              stepRepository: context.read(),
            ),
          ),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) {
            return ProfileScreen(
              userId: state.uri.queryParameters['userId'],
              viewModel: ProfileViewModel(
                authRepository: context.read(),
                userRepository: context.read(),
                planRepository: context.read(),
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.planDetails,
          builder: (context, state) {
            final planId = state.uri.queryParameters['id'];

            if (planId == null) {
              return const SizedBox
                  .shrink(); // ou redirige, mais pas dans le builder
            }

            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => PlanDetailsViewModel(
                    planRepository: context.read(),
                    locationService: context.read(),
                    authRepository: context.read(),
                    planId: planId,
                    commentRepository: context.read(),
                    userRepository: context.read(),
                  )..loadPlan(planId),
                ),
                ChangeNotifierProvider(
                  create: (context) => FavoriteViewModel(
                    context.read(),
                    context.read(),
                  )..initFavoriteStatus(planId),
                ),
                ChangeNotifierProvider(
                  create: (context) => FollowUserViewModel(
                    context.read(),
                    context.read(),
                  ),
                ),
              ],
              child: Consumer3<PlanDetailsViewModel, FavoriteViewModel,
                  FollowUserViewModel>(
                builder: (context, planVM, favoriteVM, followVM, _) {
                  return PlanDetailsScreen(
                    planId: planId,
                    planVM: planVM,
                    favoriteVM: favoriteVM,
                    followVM: followVM,
                  );
                },
              ),
            );
          },
        ),
      ],
    );

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login ||
      state.matchedLocation == Routes.register ||
      state.matchedLocation == Routes.reset ||
      state.matchedLocation == Routes.home;

  if (!loggedIn) {
    return loggingIn ? null : Routes.home;
  }

  if (loggingIn) {
    return Routes.dashboard;
  }

  return null;
}
