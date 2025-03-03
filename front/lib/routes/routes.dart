import 'package:flutter/material.dart';
import 'package:front/screens/auth/login_screen.dart';
import 'package:front/screens/auth/reset_password_screen.dart';
import 'package:front/screens/auth/signup_screen.dart';
import 'package:front/screens/dashboard/dashboard_screen.dart';
import 'package:front/screens/dashboard/map_screen.dart';
import 'package:front/screens/dashboard/plans_screen.dart';
import 'package:front/screens/home/home_screen.dart';
import 'package:front/screens/splash/splash_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/': (context) => const SplashScreen(),
      '/home': (context) => HomeScreen(),
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignupScreen(),
      '/reset-password': (context) => const ResetPasswordScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/plans': (context) => const PlansScreen(),
      '/map': (context) => const MapScreen(),
    };
  }
}
