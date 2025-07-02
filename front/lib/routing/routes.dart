import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';

import '../screens/details-plan/details_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../ui/auth/reset-password/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/home': (context) => const HomeScreen(),
      '/reset-password': (context) => const ResetPasswordScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/details': (context) => DetailScreen(),
    };
  }
}
