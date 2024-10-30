import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Exécute la vérification après que le build initial soit terminé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  // Fonction pour vérifier si un utilisateur est déjà connecté avec Firebase
  Future<void> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si l'utilisateur est connecté, redirige vers la page d'accueil
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Sinon, redirige vers la page de connexion
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
