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

    // Remplir les champs du formulaire de création de plan
    await tester.enterText(
        find.byKey(const Key('titleField')), 'Mon super plan');
    await tester.enterText(
        find.byKey(const Key('descriptionField')), 'Une description top.');

    // Ouvrir la bottom sheet de sélection de catégorie
    await tester.tap(find.byKey(const Key('categoryField')));
    await tester.pumpAndSettle();

    // Sélectionner la catégorie "Nature" (doit exister dans la liste)
    await tester.tap(find.text('Nature').first);
    await tester.pumpAndSettle();

    // Valider la création du plan
    await tester.tap(find.byKey(const Key('createPlanButton')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Vérifier que le plan apparaît dans la liste des plans (optionnel)
    expect(find.text('Mon super plan'), findsOneWidget);
  });
}
