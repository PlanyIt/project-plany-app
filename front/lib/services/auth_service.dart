import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  // Méthode de connexion
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await UserService().syncUserAfterLogin();
      // Si la connexion est réussie, renvoyer l'utilisateur Firebase
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
      throw Exception('Échec de la déconnexion : $e');
    }
  }

  // Méthode pour réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(
          'Échec de l\'envoi de l\'e-mail de réinitialisation : $e');
    }
  }

  Future<void> saveUserToMongoDB(String firebaseUid, String username,
      String description, String email) async {
    try {
      // Créer un objet contenant les informations de l'utilisateur
      var user = {
        'firebaseUid': firebaseUid,
        'username': username,
        'description': description,
        'email': email,
      };

      // Convertir l'objet en JSON
      var body = json.encode(user);

      // Envoyer une requête POST à l'API NestJS pour enregistrer l'utilisateur
      await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
    } catch (e) {
      throw Exception('Échec de l\'enregistrement de l\'utilisateur : $e');
    }
  }

  // Méthode pour réauthentifier un utilisateur (nécessaire pour les opérations sensibles)
  Future<void> reauthenticate(String password) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('Aucun utilisateur connecté');
      }
      
      // Créer des informations d'identification
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      
      // Réauthentifier l'utilisateur
      await currentUser.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Échec de réauthentification: $e');
    }
  }

  // Méthode pour mettre à jour l'email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      // Réauthentification nécessaire avant de changer l'email
      await reauthenticate(password);
      
      // Mettre à jour l'email dans Firebase
      await _auth.currentUser?.updateEmail(newEmail);
      
      // Mettre à jour dans MongoDB via votre API
      await UserService().updateUserEmail(newEmail);
      
    } catch (e) {
      throw Exception('Échec de mise à jour de l\'email: $e');
    }
  }

  // Méthode pour mettre à jour le mot de passe
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      // Réauthentification nécessaire avant de changer le mot de passe
      await reauthenticate(currentPassword);
      
      // Mettre à jour le mot de passe dans Firebase
      await _auth.currentUser?.updatePassword(newPassword);
      
    } catch (e) {
      throw Exception('Échec de mise à jour du mot de passe: $e');
    }
  }
}
