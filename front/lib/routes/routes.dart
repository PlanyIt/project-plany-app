import 'package:flutter/material.dart';
import 'package:front/screens/auth/login_screen.dart';
import 'package:front/screens/auth/reset_password_screen.dart';
import 'package:front/screens/auth/signup_screen.dart';
import 'package:front/screens/dashboard/dashboard_screen.dart';
import 'package:front/screens/dashboard/plans_screen.dart';
import 'package:front/screens/details-plan/details_screen.dart';
import 'package:front/screens/auth/home_screen.dart';
import 'package:front/screens/profile/profile_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/home': (context) => HomeScreen(),
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignupScreen(),
      '/reset-password': (context) => const ResetPasswordScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/plans': (context) => const PlansScreen(),
      '/details': (context) => DetailScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }
}
