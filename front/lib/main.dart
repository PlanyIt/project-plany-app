import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'data/services/fake_location_service.dart';
import 'data/services/location_service.dart';
import 'routing/router.dart';
import 'ui/core/localization/applocalization.dart';
import 'ui/core/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'local');

  switch (env) {
    case 'staging':
      await dotenv.load(fileName: '.env.staging');
      break;
    case 'local':
    default:
      await dotenv.load(fileName: '.env.local');
      break;
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    debugPrint('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  debugPrint("je suis l'env : $env");

  const isInTest = bool.fromEnvironment('IS_TEST');

  final locationService = isInTest ? FakeLocationService() : LocationService();

  runApp(
    MultiProvider(
      providers: [
        ...providers,
        ChangeNotifierProvider.value(value: locationService),
      ],
      child: const MainApp(),
    ),
  );

  if (!isInTest) {
    Future.delayed(const Duration(milliseconds: 500), () {
      locationService.initialize();
    });
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationDelegate(),
      ],
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      routerConfig: router(context.read()),
    );
  }
}
