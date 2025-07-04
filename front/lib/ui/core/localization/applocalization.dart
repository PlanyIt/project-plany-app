import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'errorWhileLogin': 'Error while trying to login',
      'errorWhileLogout': 'Error while trying to logout',
      'errorWhileRegister': 'Error while trying to register',
      'login': 'Login',
      'register': 'Register',
      'tryAgain': 'Try Again',
    },
    'fr': {
      'errorWhileLogin': 'Erreur lors de la tentative de connexion',
      'errorWhileLogout': 'Erreur lors de la tentative de déconnexion',
      'errorWhileRegister': 'Erreur lors de la tentative d\'inscription',
      'login': 'Connexion',
      'register': 'Inscription',
      'tryAgain': 'Réessayer',
      'searchHint': 'Rechercher des plans, des catégories...',
    },
  };

  String _get(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        '[${key.toUpperCase()}]';
  }

  String get errorWhileLogin => _get('errorWhileLogin');
  String get errorWhileLogout => _get('errorWhileLogout');
  String get errorWhileRegister => _get('errorWhileRegister');
  String get login => _get('login');
  String get register => _get('register');
  String get tryAgain => _get('tryAgain');
  String get searchHint => _get('searchHint');
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) =>
      false;
}
