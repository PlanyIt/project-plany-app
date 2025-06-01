import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion avec email et mot de passe
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de connexion: $e');
      }
      rethrow;
    }
  }

  // Inscription avec email et mot de passe
  Future<User?> register(String email, String password, String username,
      String description) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil utilisateur avec le nom d'utilisateur
      await userCredential.user?.updateDisplayName(username);

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur d\'inscription: $e');
      }
      rethrow;
    }
  }

  // Sauvegarder les informations utilisateur dans MongoDB
  Future<void> saveUserToMongoDB(
      String uid, String username, String description, String email) async {
    // Implémentez cette méthode pour stocker les données utilisateur dans MongoDB
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de déconnexion: $e');
      }
      rethrow;
    }
  }

  // Récupérer l'utilisateur actuel
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
