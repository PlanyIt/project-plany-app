import 'package:flutter/material.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/widgets/buttons/p_primarybutton.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _authService =
      AuthService(); // Création de l'instance d'AuthService

  // Méthode pour gérer la déconnexion via AuthService
  Future<void> _logout(BuildContext context) async {
    try {
      await _authService
          .logout(); // Utilisation du service AuthService pour la déconnexion
      Navigator.pushReplacementNamed(
          context, '/login'); // Redirection après déconnexion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.fitHeight,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Text(
              'Plany.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.leagueSpartan().fontFamily,
              ),
            ),
          ),

          // Bouton de déconnexion avec AuthService
          Positioned(
            top: 50,
            right: 20,
            child: PrimaryButton(
              text: 'Logout',
              onPressed: () => _logout(
                  context), // Utilisation de AuthService pour déconnecter
            ),
          ),

          Positioned(
            bottom: 100,
            left: 30,
            right: 30,
            child: PrimaryButton(
              text: "Se connecter",
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ),
          Positioned(
            bottom: 25,
            left: 30,
            right: 30,
            child: PrimaryButton(
              buttonColor: ButtonColor.secondary,
              textColor: TextColor.dark,
              text: "S'inscrire",
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ),
        ],
      ),
    );
  }
}
