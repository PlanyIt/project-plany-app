import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/step.dart';

class StepService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<List<Step>> fetchSteps() async {
    final response = await http.get(Uri.parse('$baseUrl/api/steps'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Data: $data');
      return data.map((step) => Step.fromJson(step)).toList();
    } else {
      throw Exception('Failed to load steps');
    }
  }
}
