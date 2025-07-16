import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:front/ui/create_plan/create_plan_screen.dart';
import 'package:front/ui/create_plan/view_models/create_plan_view_model.dart';
import 'package:front/ui/create_plan/view_models/create_step_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import '../../../testing/fakes/app.dart';

/// Fakes nécessaires pour mocktail
class FakePageController extends Fake implements PageController {}

class FakeBuildContext extends Fake implements BuildContext {}

/// Mock de ton ViewModel
class MockCreatePlanViewModel extends Mock implements CreatePlanViewModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePageController());
    registerFallbackValue(FakeBuildContext());
    // Supprime définitivement le warning inutile de Flutter Test
    WidgetController.hitTestWarningShouldBeFatal = false;
  });

  group('CreatePlanScreen tests', () {
    late MockCreatePlanViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockCreatePlanViewModel();
      when(() => mockViewModel.currentStep).thenReturn(ValueNotifier<int>(1));
      when(() => mockViewModel.title).thenReturn(ValueNotifier<String>(''));
      when(() => mockViewModel.description)
          .thenReturn(ValueNotifier<String>(''));
      when(() => mockViewModel.steps)
          .thenReturn(ValueNotifier<List<StepData>>([]));
      when(() => mockViewModel.isPublic).thenReturn(ValueNotifier<bool>(true));
      when(() => mockViewModel.isAccessible)
          .thenReturn(ValueNotifier<bool>(false));
      when(() => mockViewModel.handleNextStep(any()))
          .thenAnswer((_) async => true);
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        CreatePlanScreen(viewModel: mockViewModel),
      );
    }

    testWidgets('should load screen', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(CreatePlanScreen), findsOneWidget);
      });
    });

    testWidgets('should create a plan through all steps',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        mockViewModel.title.value = 'Titre du plan';
        mockViewModel.description.value = 'Description du plan';

        final continuerButton1 = find.widgetWithText(PlanyButton, 'Continuer');
        await tester.ensureVisible(continuerButton1);
        await tester.tap(continuerButton1);
        await tester.pumpAndSettle();

        // Simule étape 2
        mockViewModel.currentStep.value = 2;
        await tester.pumpAndSettle();

        mockViewModel.steps.value = [
          StepData(
            title: 'Étape 1',
            description: 'Description',
            cost: 100,
            duration: 1,
            durationUnit: 'heure',
            imageUrl: File('test/assets/fake.png').path,
          ),
        ];

        final continuerButton2 = find.widgetWithText(PlanyButton, 'Continuer');
        await tester.ensureVisible(continuerButton2);
        await tester.tap(continuerButton2);
        await tester.pumpAndSettle();

        // Simule étape 3
        mockViewModel.currentStep.value = 3;
        await tester.pumpAndSettle();

        final publierButton =
            find.widgetWithText(PlanyButton, 'Publier mon plan');
        await tester.ensureVisible(publierButton);
        await tester.tap(publierButton);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Plan créé avec succès'), findsOneWidget);

        when(() => mockViewModel.goToDashboard(any())).thenReturn(null);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        verify(() => mockViewModel.goToDashboard(any())).called(1);
        expect(find.byType(BottomBar), findsOneWidget);
      });
    });
  });
}
