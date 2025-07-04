import 'package:flutter/material.dart';

import '../screens/details-plan/details_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../ui/auth/reset-password/reset_password_screen.dart';
import '../ui/auth/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes() {
    return {
      '/home': (context) => const HomeScreen(),
      '/reset-password': (context) => const ResetPasswordScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/details': (context) => DetailScreen(),
    };
  }
}
