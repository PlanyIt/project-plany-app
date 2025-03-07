import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show delete, get, post, put;
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

Future<List<Comment>> getComments(String planId, {int page = 1, int limit = 10}) async {
  final response = await http.get(Uri.parse('$baseUrl/api/comments/plan/$planId?page=$page&limit=$limit'));
  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseData = json.decode(response.body);
    if (responseData != null && responseData['comments'] != null) {
      // Extraire le tableau comments de la réponse
      return List<Comment>.from(responseData['comments'].map((x) => Comment.fromJson(x)));
    } else {
      throw Exception('Aucun commentaire trouvé dans la réponse');
    }
  } else {
    throw Exception('Failed to load comments');
  }
}

Future<List<Comment>> getCommentResponses(String commentId) async {
  final token = await getAuthToken();
  if (token == null) throw Exception('No authentication token found');

  final response = await http.get(
    Uri.parse('$baseUrl/api/comments/$commentId/responses'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final List<dynamic> responseData = json.decode(response.body);
    return responseData.map((data) => Comment.fromJson(data)).toList();
  } else {
    throw Exception('Erreur lors de la récupération des réponses');
  }
}
  Future<void> deleteComment(String commentId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la suppression du commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<Comment> createComment(String planId, Comment comment) async {
    //userId et createdAt sont gérés par le backend
    final body = json.encode(comment.toJson());
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.post(
        Uri.parse('$baseUrl/api/comments'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Ajout du token
        },
        body: body,
      );

      // Vérification de la réponse HTTP
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Vérification que la réponse contient un ID valide
        if (responseData['_id'] == null) {
          throw Exception('Le serveur n\'a pas renvoyé d\'ID pour le commentaire');
        }
        return Comment.fromJson(responseData);
      } else {
        // Si la réponse n'est ni 200 ni 201, lancer une exception
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
          'Erreur lors de la création du commentaire : ${response.body}',
        );
      }
    } catch (error) {
      // Gérer les exceptions ou erreurs capturées
      print('Exception capturée: $error');
      rethrow;  // Propager l'erreur pour être capturée ailleurs
    }
  }

  Future<void> editComment(String commentId, Comment comment) async {
    final body = json.encode(comment.toJson());
    try {
      // Récupération du token Firebase
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      // Requête HTTP avec le token dans l’en-tête
      final response = await http.put(
        Uri.parse('$baseUrl/api/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Ajout du token
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la modification du commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  Future<Comment> getCommentById(String commentId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$baseUrl/api/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Vérification que la réponse contient un ID valide
        if (responseData['_id'] == null) {
          throw Exception('Le serveur n\'a pas renvoyé d\'ID pour le commentaire');
        }
        return Comment.fromJson(responseData);
      } else {
     
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de la récupération du commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  // like comment
  Future<void> likeComment(String commentId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$baseUrl/api/comments/$commentId/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de l\'ajout du like au commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  // unlike comment
  Future<void> unlikeComment(String commentId) async {
    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.put(
        Uri.parse('$baseUrl/api/comments/$commentId/unlike'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Erreur : ${response.statusCode} - ${response.body}');
        throw Exception(
            'Erreur lors de l\'ajout du like au commentaire : ${response.body}');
      }
    } catch (error) {
      print('Exception capturée: $error');
      rethrow;
    }
  }

  // répondre à un commentaire
  // Correction de respondToComment
Future<Comment> respondToComment(String commentId, Comment comment) async {
  final Map<String, dynamic> payload = comment.toJson();
  // Ajouter le parentId explicitement
  payload['parentId'] = commentId;
  
  final body = json.encode(payload);
  try {
    final token = await getAuthToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/api/comments/$commentId/response'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return Comment.fromJson(responseData);
    } else {
      throw Exception('Erreur lors de la création de la réponse');
    }
  } catch (error) {
    print('Exception: $error');
    rethrow;
  }
}

Future<void> deleteResponse(String commentId, String responseId) async {
  try {
    final token = await getAuthToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/comments/$commentId/response/$responseId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      print('Erreur : ${response.statusCode} - ${response.body}');
      throw Exception('Erreur lors de la suppression de la réponse : ${response.body}');
    }
  } catch (error) {
    print('Exception capturée: $error');
    rethrow;
  }
}
}