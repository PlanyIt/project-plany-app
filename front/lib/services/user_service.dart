import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Si l'API ne renvoie pas les informations, renvoyer des informations
        // basiques à partir des données Firebase
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return {
            'id': user.uid,
            'name': user.displayName ?? 'Utilisateur',
            'email': user.email,
            'description': 'Aucune description disponible',
            'plansCount': 0,
            'favoritesCount': 0,
            'followersCount': 0,
            'location': 'Non spécifiée',
          };
        } else {
          throw Exception('Utilisateur non authentifié');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du profil: $e');
      }

      // Si une erreur se produit, essayer de renvoyer des informations basiques
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return {
          'id': user.uid,
          'name': user.displayName ?? 'Utilisateur',
          'email': user.email,
          'description': 'Aucune description disponible',
          'plansCount': 0,
          'favoritesCount': 0,
          'followersCount': 0,
          'location': 'Non spécifiée',
        };
      } else {
        throw Exception('Erreur lors de la récupération du profil: $e');
      }
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Utilisateur non authentifié');

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du profil: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du profil: $e');
      }
      rethrow;
    }
  }
}
