import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/ui/core/localization/applocalization.dart';
import 'package:front/ui/core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../mocks.dart';

Future<void> testApp(
  WidgetTester tester,
  Widget body, {
  GoRouter? goRouter,
}) async {
  tester.view.devicePixelRatio = 1.0;
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await mockNetworkImages(() async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizationDelegate(),
        ],
        supportedLocales: [
          const Locale('fr', 'FR'),
        ],
        theme: AppTheme.lightTheme,
        home: InheritedGoRouter(
          goRouter: goRouter ?? MockGoRouter(),
          child: Scaffold(body: body),
        ),
      ),
    );
  });
}
