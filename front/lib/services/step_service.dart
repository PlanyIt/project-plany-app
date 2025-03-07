import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/step.dart';

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
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la création de l’étape : ${response.body}');
      }

      return json.decode(response.body)['_id'];
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<List<Step>> getSteps() async {
    final response = await http.get(Uri.parse('$baseUrl/api/steps'));
    print(response.body);
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
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la mise à jour de l’étape : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
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
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la suppression de l’étape : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<Step?> getStepById(String stepId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/steps/$stepId'));

    if (response.statusCode == 200) {
      return Step.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load step');
    }
  }
}
