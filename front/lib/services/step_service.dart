import 'dart:convert';
import 'dart:math' as Math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/step.dart';
import 'package:front/models/plan.dart'; // Import the Plan class
import 'package:front/utils/helpers.dart'; // Import helper functions for duration conversion

class StepService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<String> createStep(Step step) async {
    final body = json.encode(step.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.post(
        Uri.parse('$baseUrl/api/steps'),
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
            'Erreur lors de la création de l’étape : ${response.body}');
      }

      return json.decode(response.body)['_id'];
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<List<Step>> getSteps() async {
    final response = await http.get(Uri.parse('$baseUrl/api/steps'));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final List<dynamic> steps = json.decode(response.body);
      return steps.map((step) => Step.fromJson(step)).toList();
    } else {
      throw Exception('Failed to load steps');
    }
  }

  Future<void> updateStep(Step step) async {
    final body = json.encode(step.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.put(
        Uri.parse('$baseUrl/api/steps/${step.id}'),
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
            'Erreur lors de la mise à jour de l’étape : ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteStep(String stepId) async {
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.delete(
        Uri.parse('$baseUrl/api/steps/$stepId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (kDebugMode) {
          print('Erreur : ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Erreur lors de la suppression de l’étape : ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      rethrow;
    }
  }

  Future<Step?> getStepById(String stepId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/steps/$stepId'));
      if (response.statusCode == 200) {
        final jsonBody = response.body;

        final parsedJson = json.decode(jsonBody);

        try {
          final step = Step.fromJson(parsedJson);
          return step;
        } catch (e) {
          print("Erreur lors de la conversion JSON → Step: $e");
          return null;
        }
      } else {
        throw Exception('Failed to load step');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception capturée: $error');
      }
      return null;
    }
  }

  Future<double> calculatePlanTotalCost(Plan plan) async {
    double totalCost = 0.0;

    for (final stepId in plan.steps) {
      try {
        final step = await getStepById(stepId);
        if (step != null && step.cost != null) {
          totalCost += step.cost!;
        }
      } catch (e) {
        print('Erreur lors du calcul du coût pour l\'étape $stepId: $e');
      }
    }

    return totalCost;
  }

  int _parseDurationToMinutes(String durationStr) {
    final parts = durationStr.trim().split(' ');
    if (parts.length < 2) return 0;

    int value;
    try {
      value = int.parse(parts[0]);
    } catch (e) {
      return 0;
    }

    final unit = parts[1].toLowerCase();

    if (unit.contains('seconde')) {
      return (value / 60).ceil(); // Convert seconds to minutes, rounding up
    } else if (unit.contains('minute')) {
      return value;
    } else if (unit.contains('heure')) {
      return value * 60; // Convert hours to minutes
    } else if (unit.contains('jour')) {
      return value * 24 * 60; // Convert days to minutes
    }

    return 0;
  }

  Future<int> calculatePlanTotalDuration(Plan plan) async {
    int totalMinutes = 0;

    for (final stepId in plan.steps) {
      try {
        final step = await getStepById(stepId);
        if (step != null && step.duration != null) {
          totalMinutes +=
              _parseDurationToMinutes(step.duration!); // Use helper function
        }
      } catch (e) {
        print('Erreur lors du calcul de la durée pour l\'étape $stepId: $e');
      }
    }

    return totalMinutes;
  }
}
