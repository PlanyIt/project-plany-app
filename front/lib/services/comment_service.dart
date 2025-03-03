import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/comment.dart';

class CommentService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> getAuthToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }

  Future<List<Comment>> getComments(String planId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/comments/plan/$planId'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> comments = json.decode(response.body);
      return comments.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> createComment(String planId, Comment comment) async {
    final body = json.encode(comment.toJson());

    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.post(
        Uri.parse('$baseUrl/api/comments'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Ajout du token
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la création du commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }
}
