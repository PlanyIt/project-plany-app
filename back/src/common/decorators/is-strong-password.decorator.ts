import {
  registerDecorator,
  ValidationOptions,
  ValidatorConstraint,
  ValidatorConstraintInterface,
} from 'class-validator';
import { SECURITY_CONSTANTS } from '../constants/security.constants';

@ValidatorConstraint({ async: false })
export class IsStrongPasswordConstraint
  implements ValidatorConstraintInterface
{
  validate(password: string): boolean {
    if (!password) return false;

    const { PASSWORD_REQUIREMENTS } = SECURITY_CONSTANTS;

    // Vérifier la longueur minimale
    if (password.length < PASSWORD_REQUIREMENTS.minLength) {
      return false;
    }

    // Vérifier la présence de majuscules
    if (PASSWORD_REQUIREMENTS.requireUppercase && !/[A-Z]/.test(password)) {
      return false;
    }

    // Vérifier la présence de minuscules
    if (PASSWORD_REQUIREMENTS.requireLowercase && !/[a-z]/.test(password)) {
      return false;
    }

    // Vérifier la présence de chiffres
    if (PASSWORD_REQUIREMENTS.requireNumbers && !/\d/.test(password)) {
      return false;
    }

    // Vérifier la présence de caractères spéciaux
    if (
      PASSWORD_REQUIREMENTS.requireSpecialChars &&
      !/[!@#$%^&*(),.?":{}|<>]/.test(password)
    ) {
      return false;
    }

    return true;
  }

  defaultMessage(): string {
    const { PASSWORD_REQUIREMENTS } = SECURITY_CONSTANTS;
    return `Le mot de passe doit contenir au moins ${PASSWORD_REQUIREMENTS.minLength} caractères, incluant des majuscules, minuscules, chiffres et caractères spéciaux`;
  }
}

export function IsStrongPassword(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      constraints: [],
      validator: IsStrongPasswordConstraint,
    });
  };
}
