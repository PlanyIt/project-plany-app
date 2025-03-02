import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/models/categorie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategorieService {
  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<List<Category>> getCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.135:3000/api/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> categories = json.decode(response.body);
      return categories.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
