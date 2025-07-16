import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/model/login_request/login_request.dart';

void main() {
  group('LoginRequest', () {
    final loginRequest = LoginRequest(
      email: 'test@example.com',
      password: 'password123',
    );

    test('can be instantiated', () {
      expect(loginRequest.email, 'test@example.com');
      expect(loginRequest.password, 'password123');
    });

    test('can be serialized/deserialized', () {
      final json = loginRequest.toJson();
      final fromJson = LoginRequest.fromJson(Map<String, dynamic>.from(json));
      expect(fromJson, loginRequest);
    });
  });
}
