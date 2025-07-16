import 'dart:io';

import 'package:front/data/services/imgur_service.dart';

class FakeImgurService implements ImgurService {
  @override
  Future<String> uploadImage(File imageFile) async {
    // Simule un upload et renvoie une fausse URL
    return 'https://fake-storage.com/${imageFile.path.split('/').last}';
  }

  @override
  Future<String?> getValidAccessToken() async {
    return 'fake_access_token';
  }

  @override
  Future<String?> refreshAccessToken() async {
    return 'refreshed_fake_access_token';
  }
}
