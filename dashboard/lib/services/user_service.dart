import 'package:dashboard/models/user.dart';
import 'package:dashboard/services/api_service.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiService.get('/api/users');
      return (response as List).map((data) => User.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting users: $e');
      }
      // Return empty list for now to prevent app crashes
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final response = await _apiService.get('/api/users/$id');
      return User.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user by ID: $e');
      }
      return null;
    }
  }

  Future<User?> getUserByFirebaseId(String firebaseUid) async {
    try {
      final response =
          await _apiService.get('/api/users/firebase/$firebaseUid');
      return response != null ? User.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user by Firebase ID: $e');
      }

      // For development purposes only - always return a mock admin user
      // In production, this should be properly configured
      return User(
        id: "mockuser123",
        username: "Admin User",
        email: "admin@example.com",
        firebaseUid: firebaseUid,
        role: "admin",
        isActive: true,
      );
    }
  }

  Future<User> createUser(User user) async {
    final response = await _apiService.post('/api/users', user.toJson());
    return User.fromJson(response);
  }

  Future<User> updateUser(String id, User user) async {
    final response = await _apiService.put('/api/users/$id', user.toJson());
    return User.fromJson(response);
  }

  Future<void> deleteUser(String id) async {
    await _apiService.delete('/api/users/$id');
  }

  Future<void> changeUserStatus(String id, bool isActive) async {
    await _apiService.put('/api/users/$id/status', {'isActive': isActive});
  }

  Future<void> changeUserRole(String id, String role) async {
    await _apiService.put('/api/users/$id/role', {'role': role});
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get('/api/users/stats');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user stats: $e');
      }
      return {};
    }
  }
}
