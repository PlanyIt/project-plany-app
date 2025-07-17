import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/model/register_request/register_request.dart';

void main() {
  group('RegisterRequest', () {
    final registerRequest = RegisterRequest(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
    );

    test('can be instantiated', () {
      expect(registerRequest.username, 'testuser');
      expect(registerRequest.email, 'test@example.com');
      expect(registerRequest.password, 'password123');
    });

    test('can be serialized/deserialized', () {
      final json = registerRequest.toJson();
      final fromJson =
          RegisterRequest.fromJson(Map<String, dynamic>.from(json));
      expect(fromJson, registerRequest);
    });
  });
}
