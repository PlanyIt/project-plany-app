import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/config/dependencies.dart';
import 'package:front/ui/core/theme/app_theme.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routing/router.dart';
import 'ui/core/localization/applocalization.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('Fichier .env chargé avec succès');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur lors du chargement du fichier .env: $e');
    }
  }
  Logger.root.level = Level.ALL;

  runApp(MultiProvider(providers: providersRemote, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _router = router(context.read());
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationDelegate(),
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
