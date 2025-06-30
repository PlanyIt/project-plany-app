import 'package:flutter/material.dart';
import 'package:front/navigation/routes.dart';
import 'package:front/shared/widgets/common/plany_logo.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: PlanyLogo(fontSize: 60, bounceDot: true, dotOffset: 40),
          ),
          Positioned(
            bottom: 100,
            left: 30,
            right: 30,
            child: PlanyButton(
              text: 'Se connecter',
              onPressed: () => context.push(Routes.login),
              filled: true,
            ),
          ),
          Positioned(
            bottom: 25,
            left: 30,
            right: 30,
            child: PlanyButton(
              text: "S'inscrire",
              onPressed: () => context.push(Routes.register),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
