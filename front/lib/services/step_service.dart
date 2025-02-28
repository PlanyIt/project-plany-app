import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/steps.dart';  // Ajouté

class StepService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.1.22:3000'; // Remplacez par l'URL de votre backend

  Future<List<Steps>> fetchSteps() async {
    final response = await http.get(Uri.parse('$baseUrl/api/steps'));
    print('Response status: ${response.statusCode}');  // Ajouté
    print('Response body: ${response.body}');  // Ajouté

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Data: $data');  // Ajouté
      return data.map((step) => Steps.fromJson(step)).toList();
    } else {
      throw Exception('Failed to load steps');
    }
  }
}