class ValidationUtils {
  ValidationUtils._();

  /// Validation de l'email
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  /// Validation du mot de passe
  static String? validatePassword(String password) {
    if (password.trim().isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    } else if (password.length > 20) {
      return 'Le mot de passe ne doit pas dépasser 20 caractères';
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,20}$')
        .hasMatch(password)) {
      return 'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre';
    }
    return null;
  }

  /// Validation du nom d'utilisateur
  static String? validateUsername(String username) {
    if (username.trim().isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }
    if (username.trim().length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }
    return null;
  }

  /// Validation complète pour la connexion
  static String? validateLoginCredentials(String email, String password) {
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    return null;
  }

  /// Validation complète pour l'inscription
  static String? validateRegisterCredentials(
    String email,
    String username,
    String password,
  ) {
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final usernameError = validateUsername(username);
    if (usernameError != null) return usernameError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    return null;
  }

  /// Valide qu'une valeur minimale n'est pas supérieure à une valeur maximale
  static String? validateRange({
    required String? minValue,
    required String? maxValue,
    String fieldName = 'valeur',
  }) {
    // Si les deux sont vides, c'est valide
    if ((minValue == null || minValue.isEmpty) &&
        (maxValue == null || maxValue.isEmpty)) return null;

    double? min, max;

    // Parse les valeurs non vides
    if (minValue != null && minValue.isNotEmpty) {
      min = double.tryParse(minValue);
      if (min == null) {
        return 'Veuillez entrer un nombre valide pour le minimum';
      }
      if (min < 0) {
        return 'La valeur minimale ne peut pas être négative';
      }
    }

    if (maxValue != null && maxValue.isNotEmpty) {
      max = double.tryParse(maxValue);
      if (max == null) {
        return 'Veuillez entrer un nombre valide pour le maximum';
      }
      if (max < 0) {
        return 'La valeur maximale ne peut pas être négative';
      }
    }

    // Valider que min <= max seulement si les deux sont définies
    if (min != null && max != null && min > max) {
      return 'La ${fieldName} minimale ne peut pas être supérieure à la maximale';
    }

    return null;
  }

  /// Valide une valeur de coût
  static String? validateCost(String? value) {
    if (value == null || value.isEmpty) return null;

    final cost = double.tryParse(value);
    if (cost == null) {
      return 'Veuillez entrer un nombre valide';
    }

    if (cost < 0) {
      return 'Le coût ne peut pas être négatif';
    }

    if (cost > 10000) {
      return 'Le coût semble trop élevé';
    }

    return null;
  }

  /// Valide une valeur de durée
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) return null;

    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Veuillez entrer un nombre entier valide';
    }

    if (duration < 0) {
      return 'La durée ne peut pas être négative';
    }

    if (duration > 1000) {
      return 'La durée semble trop élevée';
    }

    return null;
  }
}
