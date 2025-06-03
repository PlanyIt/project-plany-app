import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/domain/models/user_final.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/services/user_service.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Méthode de connexion
  Future<UserModel?> login(String email, String password) async {
    try {
      var user = {
        'email': email,
        'password': password,
      };

      var body = json.encode(user);

      // Envoi de la requête de connexion à l'API
      var response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Si la connexion est réussie, on récupère l'utilisateur
        var data = json.decode(response.body);

        return data['user'] != null ? UserModel.fromJson(data['user']) : null;
      } else {
        // Si la connexion échoue, on lance une exception
        throw Exception('Échec de la connexion : ${response.reasonPhrase}');
      }
    } catch (e) {
      // Gérer les erreurs de connexion et retourner un message descriptif
      throw Exception('Échec de la connexion : $e');
    }
  }

  Future<void> register(String username, String description, String email,
      String password) async {
    try {
      var user = {
        'username': username,
        'description': description,
        'email': email,
        'password': password,
      };

      var body = json.encode(user);

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

  // Méthode de déconnexion
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
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
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
