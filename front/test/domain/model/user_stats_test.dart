import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/user/user_stats.dart';

void main() {
  group('UserStats', () {
    test('should create with correct values', () {
      final stats = UserStats(
        plansCount: 5,
        favoritesCount: 3,
        followersCount: 7,
        followingCount: 2,
      );
      expect(stats.plansCount, 5);
      expect(stats.favoritesCount, 3);
      expect(stats.followersCount, 7);
      expect(stats.followingCount, 2);
    });

    test('should support equality', () {
      final a = UserStats(
        plansCount: 1,
        favoritesCount: 2,
        followersCount: 3,
        followingCount: 4,
      );
      final b = UserStats(
        plansCount: 1,
        favoritesCount: 2,
        followersCount: 3,
        followingCount: 4,
      );
      expect(a, equals(b));
    });

    test('should support copyWith', () {
      final stats = UserStats(
        plansCount: 1,
        favoritesCount: 2,
        followersCount: 3,
        followingCount: 4,
      );
      final copy = stats.copyWith(plansCount: 10);
      expect(copy.plansCount, 10);
      expect(copy.favoritesCount, 2);
      expect(copy.followersCount, 3);
      expect(copy.followingCount, 4);
    });
  });
}
