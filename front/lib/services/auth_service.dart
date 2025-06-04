import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/domain/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  // Stockage du token JWT
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');
  }

  Future<User> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Tentative de connexion avec: $email');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Réponse du serveur: ${response.statusCode}');
        print('Contenu de la réponse: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('Structure de données reçue: $data');
        }

        if (data['access_token'] == null) {
          throw Exception('Token manquant dans la réponse');
        }

        await _saveToken(data['access_token']);

        if (data['user'] == null) {
          throw Exception('Données utilisateur manquantes dans la réponse');
        }

        final user = User.fromJson(data['user']);
        await _saveUser(user);
        return user;
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          print(
              'Échec de connexion avec statut: ${response.statusCode}, message: $errorBody');
        }
        throw Exception('Échec de connexion: $errorBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la connexion: $e');
      }
      throw Exception('Échec de connexion: ${e.toString()}');
    }
  }

  Future<User> register(String username, String description, String email,
      String password) async {
    try {
      if (kDebugMode) {
        print('Tentative d\'inscription avec: $email, $username');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'description': description,
          'email': email,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Réponse du serveur: ${response.statusCode}');
        print('Contenu de la réponse: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('Structure de données reçue: $data');
        }

        if (data['access_token'] == null) {
          throw Exception('Token manquant dans la réponse');
        }

        await _saveToken(data['access_token']);

        if (data['user'] == null) {
          throw Exception('Données utilisateur manquantes dans la réponse');
        }

        final user = User.fromJson(data['user']);
        await _saveUser(user);
        return user;
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          print(
              'Échec d\'inscription avec statut: ${response.statusCode}, message: $errorBody');
        }
        throw Exception('Échec d\'inscription: $errorBody');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de l\'inscription: $e');
      }
      throw Exception('Échec d\'inscription: ${e.toString()}');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  /// Updates the user's email address
  Future<void> updateEmail(String newEmail, String password) async {
    final String? token = await getToken();
    final user = await getUser();

    if (token == null || user == null) {
      throw Exception('Non authentifié');
    }

    // Vérifier d'abord les identifiants avant de mettre à jour l'email
    try {
      // Valider le mot de passe actuel en essayant de se connecter
      await _validateCurrentCredentials(user.email, password);

      // Si la validation réussit, procéder à la mise à jour de l'email
      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/${user.id}/email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': newEmail,
        }),
      );

      if (response.statusCode == 200) {
        // Mettre à jour l'utilisateur local avec le nouvel email
        final updatedUser = User(
            id: user.id,
            email: newEmail,
            username: user.username,
            description: user.description,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
            password: user.password);
        await _saveUser(updatedUser);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Échec de la mise à jour de l\'email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'email: $e');
      }
      rethrow;
    }
  }

  /// Valide les identifiants actuels de l'utilisateur
  Future<void> _validateCurrentCredentials(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/validate-credentials'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Mot de passe incorrect');
      }
    } catch (e) {
      throw Exception('Échec de la validation des identifiants');
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final user = await getUser();
      return user?.id;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'ID utilisateur: $e');
      }
      return null;
    }
  }
}
