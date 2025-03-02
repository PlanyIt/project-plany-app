import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/models/tag.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TagService {
  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<List<Tag>> getCategories() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.136:3000/api/tags'));
    if (response.statusCode == 200) {
      final List<dynamic> tags = json.decode(response.body);
      return tags.map((tag) => Tag.fromJson(tag)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }
}
