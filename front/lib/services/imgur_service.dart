import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/imgur_response.dart';

class ImgurService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.imgur.com/3/',
      headers: {
        'Authorization': 'Client-ID ${dotenv.env["IMGUR_CLIENT_ID"]}',
      },
    ),
  );

  Future<ImgurResponse> uploadImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path),
      });

      Response response = await _dio.post("image", data: formData);
      return ImgurResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'upload : $e");
    }
  }
}
