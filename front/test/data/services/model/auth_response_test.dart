import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/model/auth_response/auth_response.dart';

import '../../../../testing/models/user.dart';

void main() {
  group('AuthResponse', () {
    final authResponse = AuthResponse(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      currentUser: userApiModel,
    );

    test('can be instantiated', () {
      expect(authResponse.accessToken, 'access-token');
      expect(authResponse.refreshToken, 'refresh-token');
      expect(authResponse.currentUser, userApiModel);
    });

    test('can be serialized/deserialized', () {
      final expectedJson = {
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'currentUser': userApiModel.toJson(),
      };
      final fromJson = AuthResponse.fromJson(expectedJson);
      expect(fromJson, authResponse);
    });
  });
}
