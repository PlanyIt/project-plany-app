import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../screens/profile/profile_screen.dart';
import '../ui/auth/login/login_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/register/register_screen.dart';
import '../ui/auth/register/view_models/register_viewmodel.dart';
import '../ui/auth/reset-password/reset_password_screen.dart';
import '../ui/create_plan/view_models/create_plan_view_model.dart';
import '../ui/create_plan/widgets/create_plan_screen.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/dashboard/view_models/dashboard_viewmodel.dart';
import '../ui/home/home_screen.dart';
import '../ui/search_plan/view_models/search_view_model.dart';
import '../ui/search_plan/widgets/search_screen.dart';
import 'routes.dart';

/// Top go_router entry point.
///
/// Listens to changes in [AuthTokenRepository] to redirect the user
/// to /home when the user logs out.
GoRouter router(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.dashboard,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: authRepository,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            return HomeScreen();
          },
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return LoginScreen(
              viewModel: LoginViewModel(sessionManager: context.read()),
            );
          },
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) {
            return RegisterScreen(
              viewModel: RegisterViewModel(sessionManager: context.read()),
            );
          },
        ),
        GoRoute(
          path: Routes.reset,
          builder: (context, state) {
            return ResetPasswordScreen();
          },
        ),
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) {
            return DashboardScreen(
              viewModel: DashboardViewModel(
                categoryRepository: context.read(),
                authRepository: context.read(),
                planRepository: context.read(),
              ),
            );
          },
          routes: [
            GoRoute(
              name: 'search',
              path: '/search',
              builder: (context, state) {
                final initialQuery = state.uri.queryParameters['query'];
                final initialCategory = state.uri.queryParameters['category'];
                return SearchScreen(
                  viewModel: SearchViewModel(
                    planRepository: context.read(),
                    stepRepository: context.read(),
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
          builder: (context, state) {
            return CreatePlanScreen(
              viewModel: CreatePlanViewModel(
                authRepository: context.read(),
                categoryRepository: context.read(),
                planRepository: context.read(),
                stepRepository: context.read(),
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) {
            return ProfileScreen();
          },
        ),
      ],
    );

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login ||
      state.matchedLocation == Routes.register ||
      state.matchedLocation == Routes.reset ||
      state.matchedLocation == Routes.home;

  if (!loggedIn) {
    if (loggingIn) {
      return null;
    }
    return Routes.home;
  }

  if (loggingIn) {
    return Routes.dashboard;
  }

  return null;
}
