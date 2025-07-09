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
}
