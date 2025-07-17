import 'package:flutter_test/flutter_test.dart';
import 'package:front/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validateEmail', () {
      test('returns error for empty email', () {
        expect(ValidationUtils.validateEmail(''), 'L\'email est requis');
        expect(ValidationUtils.validateEmail('   '), 'L\'email est requis');
      });

      test('returns error for invalid email format', () {
        expect(
            ValidationUtils.validateEmail('test@'), 'Format d\'email invalide');
        expect(ValidationUtils.validateEmail('test@.com'),
            'Format d\'email invalide');
        expect(ValidationUtils.validateEmail('test@@domain.com'),
            'Format d\'email invalide');
      });

      test('returns null for valid emails', () {
        expect(ValidationUtils.validateEmail('test@example.com'), null);
        expect(ValidationUtils.validateEmail('user.nametag@domain.com'), null);
      });
    });

    group('validatePassword', () {
      test('returns error for empty password', () {
        expect(
            ValidationUtils.validatePassword(''), 'Le mot de passe est requis');
        expect(ValidationUtils.validatePassword('   '),
            'Le mot de passe est requis');
      });

      test('returns error for short or long password length', () {
        expect(ValidationUtils.validatePassword('abc'),
            'Le mot de passe doit contenir au moins 6 caractères');
        expect(ValidationUtils.validatePassword('a' * 21),
            'Le mot de passe ne doit pas dépasser 20 caractères');
      });

      test('returns error for missing character types', () {
        expect(ValidationUtils.validatePassword('alllowercase'),
            'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre');
        expect(ValidationUtils.validatePassword('ALLUPPERCASE'),
            'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre');
        expect(ValidationUtils.validatePassword('12345678'),
            'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre');
        expect(ValidationUtils.validatePassword('Abcdefgh'),
            'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre');
        expect(ValidationUtils.validatePassword('Abcdef12!'),
            'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre'); // ! not allowed per regex
      });

      test('returns null for valid passwords', () {
        expect(ValidationUtils.validatePassword('Abcdef12'), null);
        expect(ValidationUtils.validatePassword('StrongPass123'), null);
      });
    });

    group('validateUsername', () {
      test('returns error for empty username', () {
        expect(ValidationUtils.validateUsername(''),
            'Le nom d\'utilisateur est requis');
        expect(ValidationUtils.validateUsername('  '),
            'Le nom d\'utilisateur est requis');
      });

      test('returns error for too short username', () {
        expect(ValidationUtils.validateUsername('ab'),
            'Le nom d\'utilisateur doit contenir au moins 3 caractères');
      });

      test('returns null for valid username', () {
        expect(ValidationUtils.validateUsername('abc'), null);
        expect(ValidationUtils.validateUsername('username123'), null);
      });
    });

    group('validateLoginCredentials', () {
      test('returns email error if invalid email', () {
        expect(
          ValidationUtils.validateLoginCredentials('bademail', 'Abcdef12'),
          'Format d\'email invalide',
        );
      });

      test('returns password error if invalid password', () {
        expect(
          ValidationUtils.validateLoginCredentials('test@example.com', 'short'),
          'Le mot de passe doit contenir au moins 6 caractères',
        );
      });

      test('returns null if both valid', () {
        expect(
          ValidationUtils.validateLoginCredentials(
              'test@example.com', 'Abcdef12'),
          null,
        );
      });
    });

    group('validateRegisterCredentials', () {
      test('returns email error if invalid email', () {
        expect(
          ValidationUtils.validateRegisterCredentials(
              'bademail', 'user', 'Abcdef12'),
          'Format d\'email invalide',
        );
      });

      test('returns username error if invalid username', () {
        expect(
          ValidationUtils.validateRegisterCredentials(
              'test@example.com', 'ab', 'Abcdef12'),
          'Le nom d\'utilisateur doit contenir au moins 3 caractères',
        );
      });

      test('returns password error if invalid password', () {
        expect(
          ValidationUtils.validateRegisterCredentials(
              'test@example.com', 'user', 'short'),
          'Le mot de passe doit contenir au moins 6 caractères',
        );
      });

      test('returns null if all valid', () {
        expect(
          ValidationUtils.validateRegisterCredentials(
              'test@example.com', 'user', 'Abcdef12'),
          null,
        );
      });
    });

    group('validateRange', () {
      test('returns null if both empty', () {
        expect(ValidationUtils.validateRange(minValue: '', maxValue: ''), null);
        expect(ValidationUtils.validateRange(minValue: null, maxValue: null),
            null);
      });

      test('returns error if minValue invalid', () {
        expect(ValidationUtils.validateRange(minValue: 'abc', maxValue: '10'),
            'Veuillez entrer un nombre valide pour le minimum');
      });

      test('returns error if maxValue invalid', () {
        expect(ValidationUtils.validateRange(minValue: '5', maxValue: 'abc'),
            'Veuillez entrer un nombre valide pour le maximum');
      });

      test('returns error if minValue negative', () {
        expect(ValidationUtils.validateRange(minValue: '-1', maxValue: '10'),
            'La valeur minimale ne peut pas être négative');
      });

      test('returns error if maxValue negative', () {
        expect(ValidationUtils.validateRange(minValue: '5', maxValue: '-1'),
            'La valeur maximale ne peut pas être négative');
      });

      test('returns error if min > max', () {
        expect(ValidationUtils.validateRange(minValue: '10', maxValue: '5'),
            'La valeur minimale ne peut pas être supérieure à la maximale');
      });

      test('returns null for valid range', () {
        expect(
            ValidationUtils.validateRange(minValue: '5', maxValue: '10'), null);
        expect(
            ValidationUtils.validateRange(minValue: '', maxValue: '10'), null);
        expect(
            ValidationUtils.validateRange(minValue: '5', maxValue: ''), null);
      });
    });

    group('validateCost', () {
      test('returns null for empty cost', () {
        expect(ValidationUtils.validateCost(''), null);
        expect(ValidationUtils.validateCost(null), null);
      });

      test('returns error if not a number', () {
        expect(ValidationUtils.validateCost('abc'),
            'Veuillez entrer un nombre valide');
      });

      test('returns error if negative', () {
        expect(ValidationUtils.validateCost('-1'),
            'Le coût ne peut pas être négatif');
      });

      test('returns error if too high', () {
        expect(
            ValidationUtils.validateCost('10001'), 'Le coût semble trop élevé');
      });

      test('returns null for valid cost', () {
        expect(ValidationUtils.validateCost('0'), null);
        expect(ValidationUtils.validateCost('9999'), null);
      });
    });

    group('validateDuration', () {
      test('returns null for empty duration', () {
        expect(ValidationUtils.validateDuration(''), null);
        expect(ValidationUtils.validateDuration(null), null);
      });

      test('returns error if not an integer', () {
        expect(ValidationUtils.validateDuration('abc'),
            'Veuillez entrer un nombre entier valide');
        expect(ValidationUtils.validateDuration('12.5'),
            'Veuillez entrer un nombre entier valide');
      });

      test('returns error if negative', () {
        expect(ValidationUtils.validateDuration('-1'),
            'La durée ne peut pas être négative');
      });

      test('returns error if too high', () {
        expect(ValidationUtils.validateDuration('1001'),
            'La durée semble trop élevée');
      });

      test('returns null for valid duration', () {
        expect(ValidationUtils.validateDuration('0'), null);
        expect(ValidationUtils.validateDuration('999'), null);
      });
    });
  });
}
