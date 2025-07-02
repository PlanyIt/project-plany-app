import 'package:flutter/foundation.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/services/auth_service.dart';
import 'package:front/services/step_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlanService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final StepService stepService = StepService();

  Future<String?> getAuthToken() async {
    final AuthService authService = AuthService();
    return await authService.getToken();
  }

  Future<List<Plan>> getPlans() async {
    final response = await http.get(Uri.parse('$baseUrl/api/plans'));
    if (kDebugMode) {}
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
        if (kDebugMode) {
          print('Erreur : ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Erreur lors de la création du plan : ${response.body}');
      }

      // Parse response to get the generated ID
      final responseData = json.decode(response.body);
      return responseData['_id'];
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
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
        if (kDebugMode) {
          print('Erreur : ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Erreur lors de la mise à jour du plan : ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<bool> deletePlan(String planId) async {
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l'en-tête
      final response = await http.delete(
        Uri.parse('$baseUrl/api/plans/$planId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('Plan deleted successfully');
        }
        return true;
      } else {
        throw Exception(
            'Erreur lors de la suppression du plan : ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
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

  Future<void> addToFavorites(String planId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$baseUrl/api/plans/$planId/favorite'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout aux favoris: ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String planId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$baseUrl/api/plans/$planId/unfavorite'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors du retrait des favoris: ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<List<Plan>> searchPlans({
    String? query,
    String? category,
    double? minCost,
    double? maxCost,
    int? minDuration,
    int? maxDuration,
    String? sortBy,
    bool ascending = true,
  }) async {
    // Construire les paramètres de requête
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    // S'assurer que les valeurs de coût sont correctement formatées
    // Utiliser des entiers pour éviter les problèmes de formatage avec les décimaux
    if (minCost != null) queryParams['minCost'] = minCost.toInt().toString();
    if (maxCost != null) queryParams['maxCost'] = maxCost.toInt().toString();

    if (minDuration != null) {
      queryParams['minDuration'] = minDuration.toString();
    }
    if (maxDuration != null) {
      queryParams['maxDuration'] = maxDuration.toString();
    }
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    queryParams['order'] = ascending ? 'asc' : 'desc';

    // Debug pour vérifier les paramètres envoyés
    if (kDebugMode) {
      print('Search params: $queryParams');
    }

    final uri =
        Uri.parse('$baseUrl/api/plans').replace(queryParameters: queryParams);

    // Récupérer le token d'authentification
    final token = await getAuthToken();

    // Effectuer la requête
    final response = await http.get(
      uri,
      headers: token != null
          ? {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            }
          : {'Content-Type': 'application/json'},
    );

    if (kDebugMode) {
      print('Search URL: $uri');
      print('Response status: ${response.statusCode}');
      print(
          'Response body preview: ${response.body.substring(0, min(200, response.body.length))}...');
    }

    if (response.statusCode == 200) {
      final List<dynamic> plansJson = json.decode(response.body);
      List<Plan> plans = plansJson.map((plan) => Plan.fromJson(plan)).toList();

      // Precompute cost and duration for sorting
      final List<Map<String, dynamic>> plansWithMetrics = [];
      for (final plan in plans) {
        final cost = await stepService.calculatePlanTotalCost(plan);
        final duration = await stepService.calculatePlanTotalDuration(plan);

        plansWithMetrics.add({
          'plan': plan,
          'cost': cost,
          'duration': duration,
        });
      }

      // Sort based on the selected criteria
      if (sortBy != null) {
        plansWithMetrics.sort((a, b) {
          int result = 0;

          if (sortBy == 'cost') {
            result = (a['cost'] as double).compareTo(b['cost'] as double);
          } else if (sortBy == 'duration') {
            result = (a['duration'] as int).compareTo(b['duration'] as int);
          }

          return ascending ? result : -result;
        });
      }

      // Extract sorted plans
      plans = plansWithMetrics.map((e) => e['plan'] as Plan).toList();

      return plans;
    } else {
      throw Exception('Failed to search plans: ${response.statusCode}');
    }
  }
}
