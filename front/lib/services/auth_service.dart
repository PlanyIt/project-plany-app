import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode de connexion
  Future<User?> login(String email, String password) async {
    try {
      // Tentative de connexion via Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si la connexion est réussie, renvoyer l'utilisateur Firebase
      return userCredential.user;
    } catch (e) {
      // Gérer les erreurs de connexion et retourner un message descriptif
      throw Exception('Échec de la connexion : $e');
    }
  }

  // Méthode d'inscription
  Future<User?> register(String email, String password, String username,
      String description) async {
    try {
      // Créer un utilisateur via Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer l'identifiant Firebase (UID)
      String? firebaseUid = userCredential.user?.uid;

      // Enregistrer les informations supplémentaires dans MongoDB via l'API NestJS
      await saveUserToMongoDB(firebaseUid!, username, description, email);

      // Retourner l'utilisateur créé
      return userCredential.user;
    } catch (e) {
      // Gérer les erreurs d'inscription
      throw Exception('Échec de l\'inscription : $e');
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
        Uri.parse('http://10.0.2.2:3000/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
    } catch (e) {
      throw Exception('Échec de l\'enregistrement de l\'utilisateur : $e');
    }
  }
}
