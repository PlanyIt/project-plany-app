// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../screens/create-plan/create_plans_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/auth/register/view_models/register_viewmodel.dart';
import '../ui/auth/register/widgets/register_screen.dart';
import '../ui/auth/reset-password/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/home_screen.dart';
import 'routes_new.dart';

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
              viewModel: LoginViewModel(authRepository: context.read()),
            );
          },
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) {
            return RegisterScreen(
              viewModel: RegisterViewModel(authRepository: context.read()),
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
            return DashboardScreen();
          },
        ),
        GoRoute(
          path: Routes.createPlan,
          builder: (context, state) {
            return CreatePlansScreen();
          },
        ),
        GoRoute(
          path: Routes.profil,
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
