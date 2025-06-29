import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/auth/login/widgets/login_screen.dart';
import 'package:front/ui/auth/signup/widgets/signup_screen.dart';
import 'package:front/ui/auth/home/widgets/home_screen.dart';
import 'package:front/ui/dashboard/widgets/screen/dashboard_screen.dart';
import 'package:front/ui/create_plan/widgets/create_plan_screen.dart';
import 'package:front/ui/profil/widgets/profil_screen.dart';
import 'package:front/providers/providers.dart';
import 'package:go_router/go_router.dart';

/// Top go_router entry point.
//
/// Listens to changes in [AuthRepository] to redirect the user
/// to /login when the user logs out.
GoRouter router(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.home,
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
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: Routes.createPlan,
          builder: (context, state) => const CreatePlanScreen(),
        ),
        GoRoute(
          path: Routes.profil,
          builder: (context, state) => const ProfilScreen(),
        ),
      ],
    );

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // Check authentication status
  final container = ProviderScope.containerOf(context);
  final authRepository = container.read(authRepositoryProvider);
  final loggedIn = await authRepository.isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login ||
      state.matchedLocation == Routes.register;

  // If not logged in and not on login/register pages, redirect to home
  if (!loggedIn && !loggingIn && state.matchedLocation != Routes.home) {
    return Routes.home;
  }

  // If logged in and on login/register pages, redirect to dashboard
  if (loggedIn && loggingIn) {
    return Routes.dashboard;
  }

  return null;
}
