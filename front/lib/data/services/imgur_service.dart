import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImgurService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.imgur.com/'));

  /// Utilise le refresh_token pour obtenir un access_token
  Future<String?> refreshAccessToken() async {
    try {
      final response = await _dio.post(
        'oauth2/token',
        data: {
          'client_id': dotenv.env['IMGUR_CLIENT_ID'],
          'client_secret': dotenv.env['IMGUR_CLIENT_SECRET'],
          'grant_type': 'refresh_token',
          'refresh_token': dotenv.env['IMGUR_REFRESH_TOKEN'],
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('imgur_access_token', accessToken);
        print('🔁 Nouveau access_token obtenu via refresh_token');
        return accessToken;
      } else {
        print('❌ Échec du refresh token : ${response.data}');
        return null;
      }
    } catch (e) {
      print('❌ Exception lors du refresh : $e');
      return null;
    }
  }

  /// Récupère un access_token valide (depuis le cache ou via refresh_token)
  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('imgur_access_token');

    if (storedToken != null) {
      return storedToken;
    }

    print('⚠️ Aucun access_token stocké. Tentative de refresh...');
    return await refreshAccessToken();
  }

  /// Upload une image (base64) vers Imgur en utilisant ton compte perso
  Future<String> uploadImage(File imageFile) async {
    print('📤 Début uploadImage');

    final accessToken = await getValidAccessToken();
    if (accessToken == null) {
      throw Exception("Impossible d'obtenir un access_token valide");
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await _dio.post(
        '3/image',
        data: {
          'image': base64Image,
          'type': 'base64',
        },
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final link = response.data['data']['link'];
        print('✅ Image uploadée avec succès : $link');
        return link;
      } else {
        throw Exception('Échec upload : ${response.data}');
      }
    } catch (e) {
      print('❌ Exception pendant l\'upload : $e');
      throw Exception("Erreur lors de l'upload : $e");
    }
  }
}
