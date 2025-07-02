import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/services/auth_service.dart';

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthService _authService = AuthService();

  Future<String?> getAuthToken() async {
    return await _authService.getToken();
  }

  Future<User> getUserProfile(String userId,
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDescription = prefs.getString('user_description');
      final cachedIsPremium = prefs.getBool('user_is_premium');

      // Récupérer depuis l'API
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Récupérer l'URL de photo stockée localement
      String? cachedPhotoUrl = prefs.getString('user_photo_url');

      // Obtenir l'utilisateur actuel depuis AuthService
      final currentUser = await _authService.getUser();
      String? currentUserPhotoUrl = currentUser?.photoUrl;

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim() == '') {
          print('Utilisateur non trouvé dans MongoDB - Création automatique');

          // Obtenir les informations de l'utilisateur connecté
          final currentUser = await _authService.getUser();

          // Créer l'utilisateur dans MongoDB
          try {
            await _createUserInMongoDB(
              userId,
              currentUser?.username ?? 'Utilisateur',
              currentUser?.email ?? '',
              cachedDescription ?? '',
            );

            // Réessayer de récupérer l'utilisateur après création
            final newResponse = await http.get(
              Uri.parse('$baseUrl/api/users/$userId'),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            );

            if (newResponse.statusCode == 200 && newResponse.body.isNotEmpty) {
              var userData = json.decode(newResponse.body);
              // Stocker le mongoId en local pour le retrouver plus tard
              final prefs = await SharedPreferences.getInstance();
              if (userData['_id'] != null) {
                await prefs.setString('user_mongo_id', userData['_id']);
              }
              return User.fromJson(userData);
            }

            return User(
              id: userId,
              username: currentUser?.username ?? 'Utilisateur',
              email: currentUser?.email ?? '',
              photoUrl: cachedPhotoUrl ?? currentUserPhotoUrl,
              description: cachedDescription,
              isPremium: cachedIsPremium ?? false,
              createdAt: null,
            );
          } catch (e) {
            print('Échec création auto utilisateur: $e');
          }

          String? photoUrl = cachedPhotoUrl ?? currentUserPhotoUrl;

          return User(
            id: userId,
            username: currentUser?.username ?? 'Utilisateur',
            email: currentUser?.email ?? '',
            photoUrl: photoUrl,
            description: cachedDescription,
            isPremium: cachedIsPremium ?? false,
          );
        }

        var userData = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        if (userData['_id'] != null) {
          await prefs.setString('user_mongo_id', userData['_id']);
        }

        var userProfile = User.fromJson(userData);

        if (userProfile.photoUrl == null || userProfile.photoUrl!.isEmpty) {
          if (userId == currentUser?.id) {
            userProfile.photoUrl = cachedPhotoUrl ?? currentUserPhotoUrl;
          }
        }

        if ((userProfile.description == null ||
                userProfile.description!.isEmpty) &&
            cachedDescription != null &&
            cachedDescription.isNotEmpty) {
          userProfile.description = cachedDescription;
        }

        if (cachedIsPremium != null &&
            !userProfile.isPremium &&
            userId == currentUser?.id) {
          userProfile.isPremium = cachedIsPremium;
        }
        return userProfile;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      rethrow;
    }
  }

  // Méthode pour créer un utilisateur dans MongoDB
  Future<void> _createUserInMongoDB(
      String userId, String username, String email, String description) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'description': description,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Échec de la création de l\'utilisateur: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      rethrow;
    }
  }

  Future<List<Plan>> getUserFavoritePlans(String userId) async {
    try {
      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/favorites'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final List<dynamic> plansJson = json.decode(response.body);
        return plansJson.map((plan) => Plan.fromJson(plan)).toList();
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to load favorite plans: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des plans favoris: $e');
      rethrow;
    }
  }

  Future<List<Plan>> getUserPlans(String userId) async {
    try {
      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/plans'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final List<dynamic> plansJson = json.decode(response.body);
        return plansJson.map((plan) => Plan.fromJson(plan)).toList();
      } else {
        throw Exception('Failed to load user plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des plans: $e');
      rethrow;
    }
  }

  Future<User?> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        // Mettre à jour le cache local si nécessaire
        if (updates.containsKey('photoUrl')) {
          final prefs = await SharedPreferences.getInstance();
          if (updates['photoUrl'] != null) {
            await prefs.setString('user_photo_url', updates['photoUrl']);
          } else {
            await prefs.remove('user_photo_url');
          }
        }

        return User.fromJson(userData);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }

  Future<bool> updateUserPhoto(String userId, String photoUrl) async {
    try {
      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/photo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'photoUrl': photoUrl}),
      );

      if (response.statusCode == 200) {
        // Mettre à jour les préférences locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_url', photoUrl);

        // Tenter de mettre à jour l'utilisateur local
        final currentUser = await _authService.getUser();
        if (currentUser != null && currentUser.id == userId) {
          final updatedUser = currentUser.copyWith(photoUrl: photoUrl);
          // Mettre à jour l'utilisateur dans les préférences
          await prefs.setString('user', jsonEncode(updatedUser.toJson()));
        }

        return true;
      } else {
        throw Exception('Failed to update photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la photo: $e');
      rethrow;
    }
  }

  Future<bool> deleteUserPhoto(String userId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$userId/photo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Supprimer la photo des préférences locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_photo_url');

        // Mettre à jour l'utilisateur local
        final currentUser = await _authService.getUser();
        if (currentUser != null && currentUser.id == userId) {
          final updatedUser = currentUser.copyWith(photoUrl: null);
          // Mettre à jour l'utilisateur dans les préférences
          await prefs.setString('user', jsonEncode(updatedUser.toJson()));
        }

        return true;
      } else {
        if (kDebugMode) {
          print(
              'Erreur lors de la suppression de la photo: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to delete photo: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de la photo: $e');
      }
      rethrow;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Non authentifié');

      final currentUser = await _authService.getUser();
      if (currentUser == null) throw Exception('Utilisateur non trouvé');

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/users/${currentUser.id}/following/${targetUserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['isFollowing'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut de suivi: $e');
      return false;
    }
  }

  Future<bool> followUser(String targetUserId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Non authentifié');

      final currentUser = await _authService.getUser();
      if (currentUser == null) throw Exception('Utilisateur non trouvé');

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/users/${currentUser.id}/follow/${targetUserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      } else {
        throw Exception('Échec de l\'abonnement: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'abonnement: $e');
      rethrow;
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Non authentifié');

      final currentUser = await _authService.getUser();
      if (currentUser == null) throw Exception('Utilisateur non trouvé');

      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/users/${currentUser.id}/follow/${targetUserId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      } else {
        throw Exception('Échec du désabonnement: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors du désabonnement: $e');
      rethrow;
    }
  }

  Future<List<User>> getUserFollowers(String userId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/followers'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> followersJson = json.decode(response.body);
        return followersJson
            .map((follower) => User.fromJson(follower))
            .toList();
      } else {
        throw Exception(
            'Échec de la récupération des abonnés: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des abonnés: $e');
      rethrow;
    }
  }

  Future<List<User>> getUserFollowing(String userId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/following'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> followingJson = json.decode(response.body);
        return followingJson
            .map((following) => User.fromJson(following))
            .toList();
      } else {
        throw Exception(
            'Échec de la récupération des abonnements: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des abonnements: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/stats'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Échec de la récupération des statistiques: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      rethrow;
    }
  }

  // Mettre à jour l'email dans votre API
  Future<void> updateUserEmail(String newEmail) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Non authentifié');

      final currentUser = await _authService.getUser();
      if (currentUser == null) throw Exception('Utilisateur non trouvé');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/${currentUser.id}/email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': newEmail}),
      );

      if (response.statusCode != 200) {
        throw Exception('Échec de mise à jour de l\'email: ${response.body}');
      }

      // Mettre à jour l'utilisateur local si nécessaire
      final prefs = await SharedPreferences.getInstance();
      final updatedUser = currentUser.copyWith(email: newEmail);
      await prefs.setString('user', jsonEncode(updatedUser.toJson()));
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'email: $e');
      rethrow;
    }
  }

  Future<bool> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('Non authentifié');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/premium'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isPremium': isPremium}),
      );

      if (response.statusCode == 200) {
        // Mettre à jour les préférences locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_is_premium', isPremium);

        // Mettre à jour l'utilisateur local
        final currentUser = await _authService.getUser();
        if (currentUser != null && currentUser.id == userId) {
          final updatedUser = currentUser.copyWith(isPremium: isPremium);
          // Mettre à jour l'utilisateur dans les préférences
          await prefs.setString('user', jsonEncode(updatedUser.toJson()));
        }

        return true;
      } else {
        if (kDebugMode) {
          print(
              'Erreur lors de la mise à jour du statut premium: ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Failed to update premium status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du statut premium: $e');
      }
      rethrow;
    }
  }
}
