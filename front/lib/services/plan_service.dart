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
    if (response.statusCode == 200) {
      final List<dynamic> plans = json.decode(response.body);
      return plans.map((plan) => Plan.fromJson(plan)).toList();
    } else {
      throw Exception('Failed to load plans');
    }
  }

  Future<void> createPlan(Plan plan) async {
    final body = json.encode(plan.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
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
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<Plan> getPlanById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/plans/$id'));
    if (response.statusCode == 200) {
      return Plan.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load plan');
    }
  }
}
