import 'package:flutter/cupertino.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/dashboard/widgets/dashboard_home_screen.dart';
import 'package:front/ui/home/widgets/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';

import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/login/widgets/login_screen.dart';

/// Top go_router entry point.
///
/// Listens to changes in [AuthTokenRepository] to redirect the user
/// to /login when the user logs out.
GoRouter router(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.dashboard,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: authRepository,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            return const HomeScreen();
          },
          routes: [
            GoRoute(
              path: Routes.login,
              builder: (context, state) {
                return LoginScreen(
                  viewModel: LoginViewModel(authRepository: context.read()),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) {
            final viewModel = DashboardViewModel(
              categoryRepository: context.read(),
              userRepository: context.read(),
              planRepository: context.read(),
            );
            return DashboardHomeScreen(
              viewModel: viewModel,
            );
          },
        ),
      ],
    );

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.home;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.dashboard;
  }

  // no need to redirect at all
  return null;
}
