import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/step/step.dart';

void main() {
  group('Step', () {
    test('should create with correct values', () {
      final step = Step(
        title: 'My Step',
        description: 'Description',
        order: 1,
        image: 'image.png',
        cost: 42.0,
      );
      expect(step.title, 'My Step');
      expect(step.description, 'Description');
      expect(step.order, 1);
      expect(step.image, 'image.png');
      expect(step.cost, 42.0);
    });

    test('should support equality', () {
      final a = Step(
        title: 'A',
        description: 'B',
        order: 1,
        image: 'img',
        cost: 10,
      );
      final b = Step(
        title: 'A',
        description: 'B',
        order: 1,
        image: 'img',
        cost: 10,
      );
      expect(a, equals(b));
    });

    test('should support copyWith', () {
      final step = Step(
        title: 'A',
        description: 'B',
        order: 1,
        image: 'img',
        cost: 10,
      );
      final copy = step.copyWith(title: 'NEW');
      expect(copy.title, 'NEW');
      expect(copy.description, 'B');
      expect(copy.order, 1);
      expect(copy.image, 'img');
      expect(copy.cost, 10);
    });
  });
}
