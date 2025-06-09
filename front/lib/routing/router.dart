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
              stepRepository: context.read(),
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
  // Check authentication status
  final authRepository = context.read<AuthRepository>();
  final loggedIn = await authRepository.isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  final isHomePage = state.matchedLocation == Routes.home;

  // If not logged in or token expired, allow access to home and login pages, but redirect other requests to home
  if (!loggedIn) {
    if (loggingIn || isHomePage) {
      return null; // No redirection needed
    }
    return Routes.home; // Redirect all other routes to home
  }

  // If the user is logged in but still on the home or login page, send them to the dashboard
  if (loggingIn || isHomePage) {
    return Routes.dashboard;
  }

  // No need to redirect at all
  return null;
}
