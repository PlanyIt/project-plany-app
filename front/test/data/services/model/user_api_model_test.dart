import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/api/model/user/user_api_model.dart';

void main() {
  group('UserApiModel', () {
    test('fromJson and toJson work correctly', () {
      final json = {
        '_id': '123',
        'username': 'testuser',
        'email': 'test@example.com',
        'description': 'desc',
        'isPremium': true,
        'photoUrl': 'http://photo.url',
        'birthDate': '2000-01-01T00:00:00.000',
        'gender': 'male',
        'followers': ['a', 'b'],
        'following': ['c'],
        'followersCount': 2,
        'followingCount': 1,
        'plansCount': 5,
        'favoritesCount': 3,
      };

      final model = UserApiModel.fromJson(json);

      expect(model.id, '123');
      expect(model.username, 'testuser');
      expect(model.email, 'test@example.com');
      expect(model.description, 'desc');
      expect(model.isPremium, true);
      expect(model.photoUrl, 'http://photo.url');
      expect(model.birthDate, DateTime.parse('2000-01-01T00:00:00.000'));
      expect(model.gender, 'male');
      expect(model.followers, ['a', 'b']);
      expect(model.following, ['c']);
      expect(model.followersCount, 2);
      expect(model.followingCount, 1);
      expect(model.plansCount, 5);
      expect(model.favoritesCount, 3);

      final toJson = model.toJson();
      expect(toJson['_id'], '123');
      expect(toJson['username'], 'testuser');
      expect(toJson['email'], 'test@example.com');
      expect(toJson['description'], 'desc');
      expect(toJson['isPremium'], true);
      expect(toJson['photoUrl'], 'http://photo.url');
      expect(toJson['birthDate'], '2000-01-01T00:00:00.000');
      expect(toJson['gender'], 'male');
      expect(toJson['followers'], ['a', 'b']);
      expect(toJson['following'], ['c']);
      expect(toJson['followersCount'], 2);
      expect(toJson['followingCount'], 1);
      expect(toJson['plansCount'], 5);
      expect(toJson['favoritesCount'], 3);
    });

    test('default values are correct', () {
      final model = UserApiModel(
        id: 'id',
        username: 'u',
        email: 'e',
      );
      expect(model.isPremium, false);
      expect(model.followers, []);
      expect(model.following, []);
    });
  });
}
