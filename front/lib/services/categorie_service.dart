import 'dart:ui';

import 'package:flutter/foundation.dart' hide Category;
import 'package:front/domain/models/category/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategorieService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

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

  Future<Category> getCategoryById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories/$id'));
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  static Color getColorFromHex(String? hexColor) {
    try {
      if (hexColor != null && hexColor.isNotEmpty) {
        return Color(int.parse('0xFF${hexColor}'));
      }
    } catch (e) {
      print("Erreur lors de la conversion de couleur: $e");
    }
    return const Color(0xFF3425B5);
  }
}
