import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../screens/create-plan/create_plans_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../ui/auth/home_screen.dart';
import '../ui/auth/login/login_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/register/register_screen.dart';
import '../ui/auth/register/view_models/register_viewmodel.dart';
import '../ui/auth/reset-password/reset_password_screen.dart';
import '../ui/dashboard/view_models/dashboard_viewmodel.dart';
import '../ui/dashboard/widgets/dashboard_screen.dart';
import '../ui/search_plan/view_models/search_view_model.dart';
import '../ui/search_plan/widgets/search_screen.dart';
import 'routes.dart';

final router = GoRouter(
  initialLocation: Routes.home,
  redirect: _redirect,
  routes: [
    // Public routes
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(
          authRepository: context.read(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => RegisterScreen(
        viewModel: RegisterViewModel(
          authRepository: context.read(),
        ),
      ),
    ),

    // Protected routes
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) {
        return DashboardScreen(
          viewModel: DashboardViewModel(
            categoryRepository: context.read(),
            authRepository: context.read(),
            planRepository: context.read(),
            stepRepository: context.read(),
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
      path: Routes.profil,
      builder: (context, state) {
        // Extract userId from query parameters if provided
        final userId = state.uri.queryParameters['userId'];
        return ProfileScreen(
          userId: userId,
          isCurrentUser: userId == null,
        );
      },
    ),

    // User profile with ID (for viewing other users)
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return ProfileScreen(
          userId: userId,
          isCurrentUser: false,
        );
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
