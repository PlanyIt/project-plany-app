import 'package:flutter/cupertino.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:front/ui/auth/login/widgets/login_screen.dart';
import 'package:front/ui/auth/signup/view_models/signup_viewmodel.dart';
import 'package:front/ui/auth/signup/widgets/signup_screen.dart';
import 'package:front/ui/create_plan/view_models/create_plan_viewmodel.dart';
import 'package:front/ui/create_plan/widgets/step_one_content.dart';
import 'package:front/ui/create_plan/widgets/step_three_content.dart';
import 'package:front/ui/create_plan/widgets/step_two_content.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/dashboard/widgets/screen/dashboard_screen.dart';
import 'package:front/ui/auth/home/widgets/home_screen.dart';
import 'package:front/ui/dashboard/widgets/screen/search_screen.dart';
import 'package:front/ui/details_plan/view_models/details_plan_viewmodel.dart';
import 'package:front/ui/details_plan/widgets/details_plan_screen.dart';
import 'package:front/ui/profil/view_models/profil_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:front/ui/create_plan/widgets/create_plan_screen.dart';
import 'package:front/ui/profil/widgets/profil_screen.dart';

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
                  viewModel: LoginViewModel(sessionManager: context.read()),
                );
              },
            ),
            GoRoute(
              path: Routes.register,
              builder: (context, state) {
                return SignupScreen(
                  viewModel: SignupViewModel(
                    sessionManager: context.read(),
                  ),
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
              sessionManager: context.read(),
            );
            return DashboardScreen(
              viewModel: viewModel,
            );
          },
          routes: [
            GoRoute(
              path: Routes.search,
              builder: (context, state) {
                final viewModel = DashboardViewModel(
                  categoryRepository: context.read(),
                  userRepository: context.read(),
                  planRepository: context.read(),
                  stepRepository: context.read(),
                  sessionManager: context.read(),
                );
                return SearchScreen(
                  viewModel: viewModel,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.profil,
          builder: (context, state) {
            return ProfilScreen(
              viewModel: ProfilViewModel(
                userRepository: context.read(),
                categoryRepository: context.read(),
                planRepository: context.read(),
                stepRepository: context.read(),
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.detailsPlan,
          name: 'detailsPlan', // Add a name for the route
          builder: (context, state) {
            final planId = state.uri.queryParameters['planId'];
            return DetailScreen(
              viewModel: DetailsPlanViewModel(
                userRepository: context.read(),
                categoryRepository: context.read(),
                planRepository: context.read(),
                stepRepository: context.read(),
                commentRepository: context.read(),
              ),
              planId: planId ?? '',
            );
          },
        ),
        GoRoute(
            path: Routes.createPlan,
            builder: (context, state) {
              return CreatePlanScreen(
                viewModel: CreatePlanViewModel(
                  planRepository: context.read(),
                  stepRepository: context.read(),
                  categoryRepository: context.read(),
                  userRepository: context.read(),
                ),
              );
            },
            routes: [
              GoRoute(
                path: Routes.stepOne,
                builder: (context, state) {
                  return StepOneContent(
                    viewModel: CreatePlanViewModel(
                      planRepository: context.read(),
                      stepRepository: context.read(),
                      categoryRepository: context.read(),
                      userRepository: context.read(),
                    ),
                  );
                },
              ),
              GoRoute(
                path: Routes.stepTwo,
                builder: (context, state) {
                  return StepTwoContent(
                    viewModel: CreatePlanViewModel(
                      planRepository: context.read(),
                      stepRepository: context.read(),
                      categoryRepository: context.read(),
                      userRepository: context.read(),
                    ),
                  );
                },
              ),
              GoRoute(
                path: Routes.stepThree,
                builder: (context, state) {
                  return StepThreeContent(
                    viewModel: CreatePlanViewModel(
                      planRepository: context.read(),
                      stepRepository: context.read(),
                      categoryRepository: context.read(),
                      userRepository: context.read(),
                    ),
                  );
                },
              ),
            ]),
      ],
    );

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // Check authentication status
  final authRepository = context.read<AuthRepository>();
  final loggedIn = await authRepository.isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login ||
      state.matchedLocation == Routes.register;
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
