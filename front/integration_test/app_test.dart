import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User peut se connecter depuis Home et créer un plan',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Attendre d'être sur la Home
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(const Key('loginButtonHome')), findsOneWidget);

    // Cliquer sur login
    await tester.tap(find.byKey(const Key('loginButtonHome')));
    await tester.pumpAndSettle();

    // Remplir formulaire de login
    await tester.enterText(
        find.byKey(const Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'Test1234');

    await tester.tap(find.byKey(const Key('loginButtonForm')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Aller sur la page "Créer un plan" via la bottom bar
    await tester.tap(find.byTooltip('Créer'));
    await tester.pumpAndSettle();

    // Remplir les champs
    await tester.enterText(
        find.byKey(const Key('titleField')), 'Mon super plan');
    await tester.enterText(
        find.byKey(const Key('descriptionField')), 'Une description top.');
  });
}
