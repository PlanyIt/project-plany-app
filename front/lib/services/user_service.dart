import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/domain/models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<UserProfile> getUserProfile(String firebaseUid,
      {bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDescription = prefs.getString('user_description');
      final cachedIsPremium = prefs.getBool('user_is_premium');

      // Récupérer les données Firebase
      final user = FirebaseAuth.instance.currentUser;

      // Récupérer depuis l'API
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$firebaseUid'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Récupérer l'URL de photo stockée localement en premier
      String? cachedPhotoUrl = prefs.getString('user_photo_url');

      // Récupérer l'URL de photo de Firebase Auth
      String? firebasePhotoUrl = user?.photoURL;

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim() == '') {
          print('Utilisateur non trouvé dans MongoDB - Création automatique');

          // Récupérer les infos de Firebase Auth
          final user = FirebaseAuth.instance.currentUser;

          // Créer l'utilisateur dans MongoDB
          try {
            await _createUserInMongoDB(
              firebaseUid,
              user?.displayName ?? 'Utilisateur',
              user?.email ?? '',
              cachedDescription ?? '',
            );

            // Réessayer de récupérer l'utilisateur après création
            final newResponse = await http.get(
              Uri.parse('$baseUrl/api/users/$firebaseUid'),
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
              return UserProfile.fromJson(userData);
            }

            return UserProfile(
              id: firebaseUid,
              mongoId: null,
              username: user?.displayName ?? 'Utilisateur',
              email: user?.email ?? '',
              photoUrl: cachedPhotoUrl ?? firebasePhotoUrl,
              description: cachedDescription,
              isPremium: cachedIsPremium ?? false,
              createdAt: null,
            );
          } catch (e) {
            print('Échec création auto utilisateur: $e');
          }

          String? photoUrl = cachedPhotoUrl ?? firebasePhotoUrl;

          return UserProfile(
            id: firebaseUid,
            username: user?.displayName ?? 'Utilisateur',
            email: user?.email ?? '',
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

        var userProfile = UserProfile.fromJson(userData);

        if (userProfile.photoUrl == null || userProfile.photoUrl!.isEmpty) {
          if (firebaseUid == FirebaseAuth.instance.currentUser?.uid) {
            userProfile.photoUrl = cachedPhotoUrl ?? firebasePhotoUrl;
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
            firebaseUid == FirebaseAuth.instance.currentUser?.uid) {
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

  Future<List<Plan>> getUserFavoritePlans(String firebaseUid) async {
    try {
      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$firebaseUid/favorites'),
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
      print('Exception dans getUserFavoritePlans: $e');
      return [];
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
        print('Error response body: ${response.body}');
        throw Exception('Failed to load user plans: ${response.body}');
      }
    } catch (e) {
      print('Exception dans getUserPlans: $e');
      return [];
    }
  }

  Future<UserProfile> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final userExists = await _checkUserExistsInMongoDB(userId);

      // Si l'utilisateur n'existe pas, le créer d'abord
      if (!userExists) {
        print('Utilisateur non trouvé avant mise à jour - création automatique');
        final user = FirebaseAuth.instance.currentUser;
        await _createUserInMongoDB(
          userId,
          user?.displayName ?? data['username'] ?? 'Utilisateur',
          user?.email ?? '',
          data['description'] ?? '',
        );
      }

      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (data.containsKey('username')) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final currentPhotoURL = user.photoURL;
            await user.updateProfile(
              displayName: data['username'],
              photoURL: currentPhotoURL,
            );
          }
        } catch (e) {
          print('Erreur mise à jour Firebase Auth: $e');
        }
      }

      final prefs = await SharedPreferences.getInstance();

      if (data.containsKey('description')) {
        try {
          await prefs.setString('user_description', data['description']);
        } catch (e) {
          print('Erreur stockage local description: $e');
        }
      }

      if (data.containsKey('birthDate') && data['birthDate'] != null) {
        try {
          String birthDateStr;
          if (data['birthDate'] is DateTime) {
            DateTime originalDate = data['birthDate'] as DateTime;
            DateTime utcDate = DateTime.utc(
              originalDate.year,
              originalDate.month,
              originalDate.day,
              12,
              0,
              0,
            );
            birthDateStr = utcDate.toIso8601String();
          } else {
            DateTime parsedDate = DateTime.parse(data['birthDate'].toString());
            DateTime utcDate = DateTime.utc(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              12,
              0,
              0,
            );
            birthDateStr = utcDate.toIso8601String();
          }

          await prefs.setString('user_birth_date', birthDateStr);
        } catch (e) {
          print('Erreur stockage local birthDate: $e');
        }
      }

      if (data.containsKey('gender')) {
        try {
          await prefs.setString('user_gender', data['gender']);
        } catch (e) {
          print('Erreur stockage local gender: $e');
        }
      }

      if (response.statusCode == 200) {
        UserProfile updatedProfile;

        if (response.body.isEmpty || response.body.trim() == '') {
          final user = FirebaseAuth.instance.currentUser;

          final savedDescription = prefs.getString('user_description');
          final savedBirthDate = prefs.getString('user_birth_date');
          final savedGender = prefs.getString('user_gender');
          final isPremium = prefs.getBool('user_is_premium') ?? false;

          updatedProfile = UserProfile(
            id: userId,
            username: data['username'] ?? user?.displayName ?? 'Utilisateur',
            email: user?.email ?? '',
            photoUrl: user?.photoURL,
            description: data['description'] ?? savedDescription,
            birthDate: data['birthDate'] != null
                ? DateTime.parse(data['birthDate'])
                : (savedBirthDate != null
                    ? DateTime.parse(savedBirthDate)
                    : null),
            gender: data['gender'] ?? savedGender,
            isPremium: data['isPremium'] ?? isPremium,
            createdAt: null,
          );
        } else {
          updatedProfile = UserProfile.fromJson(json.decode(response.body));

          if (updatedProfile.description != null) {
            await prefs.setString(
                'user_description', updatedProfile.description!);
          }

          if (updatedProfile.birthDate != null) {
            await prefs.setString(
                'user_birth_date', updatedProfile.birthDate!.toIso8601String());
          }

          if (updatedProfile.gender != null) {
            await prefs.setString('user_gender', updatedProfile.gender!);
          }
        }

        return updatedProfile;
      } else {
        throw Exception(
            'Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception dans updateUserProfile: $e');
      rethrow;
    }
  }

  Future<bool> updateUserPhoto(String userId, String photoUrl) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final firebaseUid = firebaseUser?.uid ?? userId;

      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$firebaseUid/photo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'photoUrl': photoUrl}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_url', photoUrl);

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final currentDisplayName = user.displayName;
            await user.updateProfile(
              photoURL: photoUrl,
              displayName: currentDisplayName,
            );
          }
        } catch (e) {
          print('Erreur lors de la mise à jour de la photo Firebase Auth: $e');
        }

        return true;
      } else {
        throw Exception(
            'Failed to update photo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception lors de la mise à jour de la photo: $e');
      rethrow;
    }
  }

  Future<bool> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      final idForPremium = await getIdForOperation(userId, 'premium');

      final token = await getAuthToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/users/$idForPremium/premium'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'isPremium': isPremium}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_is_premium', isPremium);

        return true;
      } else {
        throw Exception(
            'Failed to update premium status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut premium: $e');
      rethrow;
    }
  }

  Future<bool> checkPremiumStatus(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStatus = prefs.getBool('user_is_premium');

      if (cachedStatus == true) return true;

      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/premium'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isPremium = data['isPremium'] ?? false;

        await prefs.setBool('user_is_premium', isPremium);

        return isPremium;
      } else {
        return cachedStatus ?? false;
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut premium: $e');
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('user_is_premium') ?? false;
    }
  }

  Future<void> _createUserInMongoDB(String firebaseUid, String username,
      String email, String description) async {
    try {
      var user = {
        'firebaseUid': firebaseUid,
        'username': username,
        'email': email,
        'description': description,
      };

      var body = json.encode(user);

      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur création utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la création dans MongoDB: $e');
      rethrow;
    }
  }

  Future<bool> _checkUserExistsInMongoDB(String firebaseUid) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$firebaseUid'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 && response.body.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de l\'existence: $e');
      return false;
    }
  }

  Future<String> getIdForOperation(String userId, String operation) async {
    if (operation == 'profile') {
      final prefs = await SharedPreferences.getInstance();
      final mongoId = prefs.getString('user_mongo_id');
      if (mongoId != null && mongoId.isNotEmpty) {
        return mongoId;
      }
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.uid;
    }

    return userId;
  }

  Future<void> syncUserAfterLogin() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await getUserProfile(currentUser.uid);
    } catch (e) {
      print('Erreur lors de la synchronisation après connexion: $e');
    }
  }

  Future<bool> followUser(String targetUserId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final followerId = currentUser.uid;

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/$followerId/follow/$targetUserId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? true;
      } else {
        print('Erreur HTTP: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception dans followUser: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final followerId = currentUser.uid;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/$followerId/unfollow/$targetUserId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? true;
      } else {
        print('Erreur désabonnement: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception dans unfollowUser: $e');
      return false;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/users/${currentUser.uid}/following/$targetUserId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isFollowing'] ?? false;
      }

      return false;
    } catch (e) {
      print('Exception dans isFollowing: $e');
      return false;
    }
  }

  Future<List<UserProfile>> getUserFollowers(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/followers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        if (data[0] is String) {
          final List<UserProfile> users = [];

          for (String id in data) {
            try {
              final response = await http.get(
                Uri.parse('$baseUrl/api/users/$id'),
                headers: {'Content-Type': 'application/json'},
              );

              if (response.statusCode == 200) {
                final userData = json.decode(response.body);
                users.add(UserProfile.fromJson(userData));
              }
            } catch (e) {
              print('Erreur: $e');
            }
          }

          return users;
        } else {
          return data
              .map<UserProfile>((user) => UserProfile.fromJson(user))
              .toList();
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception dans getUserFollowers: $e');
      return [];
    }
  }

  Future<List<UserProfile>> getUserFollowing(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/following'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        final List<UserProfile> users =
            data.map((user) => UserProfile.fromJson(user)).toList();
        return users;
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception dans getUserFollowing: $e');
      return [];
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'plansCount': data['plansCount'] ?? 0,
          'favoritesCount': data['favoritesCount'] ?? 0,
          'followersCount': data['followersCount'] ?? 0,
          'followingCount': data['followingCount'] ?? 0,
        };
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return await _calculateUserStatsManually(userId);
      }
    } catch (e) {
      print('Exception dans getUserStats: $e');
      return await _calculateUserStatsManually(userId);
    }
  }

  Future<Map<String, int>> _calculateUserStatsManually(String userId) async {
    int plansCount = 0;
    int favoritesCount = 0;

    try {
      final plans = await getUserPlans(userId);
      plansCount = plans.length;

      final favorites = await getUserFavoritePlans(userId);
      favoritesCount = favorites.length;
    } catch (e) {
      print('Erreur lors du calcul manuel: $e');
    }

    return {
      'plansCount': plansCount,
      'favoritesCount': favoritesCount,
      'followersCount': 0,
      'followingCount': 0,
    };
  }

  // Mettre à jour l'email dans votre API
  Future<void> updateUserEmail(String newEmail) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Utilisateur non authentifié');
      
      await http.patch(
        Uri.parse('$baseUrl/api/users/email/$uid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': newEmail}),
      );
    } catch (e) {
      throw Exception('Échec de mise à jour de l\'email: $e');
    }
  }
}
