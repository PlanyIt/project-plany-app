import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getAuthToken() async {
    User? user = _auth.currentUser;
    try {
      return user != null ? await user.getIdToken() : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();

      if (kDebugMode) {
        // For development only - simulate API responses
        await Future.delayed(const Duration(milliseconds: 500));
        return _getMockResponse(endpoint);
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('GET request error: $e');
      }
      throw Exception('Failed to perform GET request: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();

      if (kDebugMode) {
        // For development only - simulate API responses
        await Future.delayed(const Duration(milliseconds: 500));
        return data;
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('POST request error: $e');
      }
      throw Exception('Failed to perform POST request: $e');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();

      if (kDebugMode) {
        // For development only - simulate API responses
        await Future.delayed(const Duration(milliseconds: 500));
        return data;
      }

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('PUT request error: $e');
      }
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();

      if (kDebugMode) {
        // For development only - simulate API responses
        await Future.delayed(const Duration(milliseconds: 500));
        return null;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('DELETE request error: $e');
      }
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        print('API error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  // Mock responses for development
  dynamic _getMockResponse(String endpoint) {
    if (endpoint.startsWith('/api/users')) {
      return [
        {
          "_id": "user1",
          "username": "john_doe",
          "email": "john@example.com",
          "firebaseUid": "firebase123",
          "role": "admin",
          "isActive": true,
          "registrationDate": "2023-01-15T10:30:00Z"
        },
        {
          "_id": "user2",
          "username": "jane_smith",
          "email": "jane@example.com",
          "firebaseUid": "firebase456",
          "role": "user",
          "isActive": true,
          "registrationDate": "2023-02-20T14:45:00Z"
        }
      ];
    } else if (endpoint.startsWith('/api/categories')) {
      return [
        {
          "_id": "cat1",
          "name": "Travel",
          "icon": "✈️",
          "description": "Travel plans and guides",
          "isActive": true
        },
        {
          "_id": "cat2",
          "name": "Cooking",
          "icon": "🍳",
          "description": "Cooking recipes and tips",
          "isActive": true
        },
        {
          "_id": "cat3",
          "name": "Fitness",
          "icon": "💪",
          "description": "Workout routines and fitness plans",
          "isActive": true
        }
      ];
    } else if (endpoint.startsWith('/api/plans')) {
      return [
        {
          "_id": "plan1",
          "title": "Trip to Paris",
          "description": "A complete guide for Paris trip",
          "category": "cat1",
          "userId": "user1",
          "steps": ["Book flight", "Reserve hotel", "Plan itinerary"],
          "isPublic": true,
          "createdAt": "2023-03-10T08:15:00Z",
          "updatedAt": "2023-03-15T11:20:00Z",
          "viewCount": 120,
          "likeCount": 45,
          "saveCount": 30
        },
        {
          "_id": "plan2",
          "title": "Italian Pasta Recipe",
          "description": "Authentic Italian pasta recipe",
          "category": "cat2",
          "userId": "user2",
          "steps": [
            "Prepare ingredients",
            "Cook pasta",
            "Make sauce",
            "Combine and serve"
          ],
          "isPublic": true,
          "createdAt": "2023-04-05T16:30:00Z",
          "updatedAt": "2023-04-06T09:45:00Z",
          "viewCount": 85,
          "likeCount": 32,
          "saveCount": 18
        }
      ];
    }

    return [];
  }
}
