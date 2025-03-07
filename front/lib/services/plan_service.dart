import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/models/plan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlanService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<List<Plan>> getPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/api/plans'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> plans = json.decode(response.body);
      return plans.map((plan) => Plan.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Future<String> createPlan(Plan plan) async {
    final body = json.encode(plan.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l'en-tête
      final response = await http.post(
        Uri.parse('$baseUrl/api/plans'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la création du plan : ${response.body}');
      }

      // Parse response to get the generated ID
      final responseData = json.decode(response.body);
      return responseData['_id'];
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<void> updatePlan(Plan plan) async {
    final body = json.encode(plan.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.put(
        Uri.parse('$baseUrl/api/plans/${plan.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la mise à jour du plan : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.delete(
        Uri.parse('$baseUrl/api/plans/$planId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la suppression du plan : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<Plan> getPlanById(String planId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/plans/$planId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> plan = json.decode(response.body);
      return Plan.fromJson(plan);
    } else {
      throw Exception('Failed to load plan');
    }
  }
}
