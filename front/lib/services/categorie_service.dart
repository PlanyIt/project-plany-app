import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:front/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategorieService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> categories = json.decode(response.body);

      List<Category> result = categories.map((category) {
        if (kDebugMode) {
          print(category);
        }
        return Category.fromJson(category);
      }).toList();

      if (kDebugMode) {
        print(result);
      }
      return result;
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
