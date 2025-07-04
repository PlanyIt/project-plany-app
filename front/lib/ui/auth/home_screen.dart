import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

<<<<<<< HEAD:front/lib/ui/auth/widgets/home_screen.dart
import '../../../routing/routes.dart';
import '../../core/ui/button/plany_button.dart';
import '../../core/ui/logo/plany_logo.dart';
=======
import '../../routing/routes_new.dart';
import '../core/ui/button/plany_button.dart';
import '../core/ui/logo/plany_logo.dart';
>>>>>>> e156ae61f55f43d9ffaea3caaed364c88c0cb62e:front/lib/ui/auth/home_screen.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dotController.forward();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          Center(
              child: PlanyLogo(fontSize: 60, bounceDot: true, dotOffset: 40)),
          _buildLoginButton(context),
          _buildRegisterButton(context),
        ],
      ),
    );
  }

  Widget _buildBackground() => Image.asset(
        'assets/images/background.png',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );

  Widget _buildOverlay() => Container(
        color: Colors.black.withValues(alpha: 0.7),
        height: double.infinity,
        width: double.infinity,
      );

  Widget _buildLoginButton(BuildContext context) => Positioned(
        bottom: 100,
        left: 30,
        right: 30,
        child: PlanyButton(
          text: 'Se connecter',
          onPressed: () => context.push(Routes.login),
          filled: true,
        ),
      );

  Widget _buildRegisterButton(BuildContext context) => Positioned(
        bottom: 25,
        left: 30,
        right: 30,
        child: PlanyButton(
          text: "S'inscrire",
          onPressed: () => context.push(Routes.register),
          filled: false,
        ),
      );
}
