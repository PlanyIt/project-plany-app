import 'package:flutter_test/flutter_test.dart';
import 'package:front/utils/result.dart';

void main() {
  group('Result', () {
    test('Ok creates successful result with value', () {
      final result = Result<int>.ok(42);
      expect(result, isA<Ok<int>>());
      expect(result is Ok<int>, true);
      expect((result as Ok<int>).value, 42);
      expect(result.toString(), 'Result<int>.ok(42)');
    });

    test('Error creates error result with exception', () {
      final exception = Exception('error');
      final result = Result<int>.error(exception);
      expect(result, isA<Error<int>>());
      expect(result is Error<int>, true);
      expect((result as Error<int>).error, exception);
      expect(result.toString(), 'Result<int>.error(Exception: error)');
    });

    test('Result.ok and Result.error are different types', () {
      final okResult = Result<String>.ok('test');
      final errorResult = Result<String>.error(Exception('fail'));

      expect(okResult, isNot(equals(errorResult)));
      expect(okResult.runtimeType, isNot(equals(errorResult.runtimeType)));
    });
  });
}
