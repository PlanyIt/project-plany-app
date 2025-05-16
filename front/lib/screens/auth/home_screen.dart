import 'package:flutter/material.dart';
import 'package:front/widgets/common/plany_logo.dart';
import 'package:front/widgets/common/plany_button.dart';

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
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
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
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              filled: true,
            ),
          ),
          Positioned(
            bottom: 25,
            left: 30,
            right: 30,
            child: PlanyButton(
              text: "S'inscrire",
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
