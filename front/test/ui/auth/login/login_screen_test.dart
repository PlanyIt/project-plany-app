import 'package:flutter_test/flutter_test.dart';
import 'package:front/ui/auth/login/login_screen.dart';
import 'package:front/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:front/ui/core/ui/form/custom_text_field.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../../testing/fakes/app.dart';
import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../../testing/fakes/repositories/fake_step_repository.dart';
import '../../../../testing/fakes/services/fake_session_manager.dart';
import '../../../../testing/mocks.dart';

void main() {
  group('LoginScreen tests', () {
    late LoginViewModel viewModel;
    late MockGoRouter goRouter;
    late FakeAuthRepository fakeAuthRepository;
    late FakePlanRepository fakePlanRepository;
    late FakeCategoryRepository fakeCategoryRepository;
    late FakeSessionManager fakeSessionManager;

    setUp(() {
      goRouter = MockGoRouter();
      fakeAuthRepository = FakeAuthRepository();
      fakePlanRepository = FakePlanRepository();
      fakeCategoryRepository = FakeCategoryRepository();
      fakeSessionManager = FakeSessionManager(
        authRepository: fakeAuthRepository,
        planRepository: fakePlanRepository,
        categoryRepository: fakeCategoryRepository,
        stepRepository: FakeStepRepository(),
      );

      viewModel = LoginViewModel(sessionManager: fakeSessionManager);

      // Important : mock le comportement pour éviter les erreurs.
      when(() => goRouter.go(any())).thenReturn(null);
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        LoginScreen(viewModel: viewModel),
        goRouter: goRouter,
      );
    }

    testWidgets('should load screen', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    });

    testWidgets('should perform login', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        await tester.enterText(
            find.byType(CustomTextField).at(0), 'email@email.com');
        await tester.enterText(find.byType(CustomTextField).at(1), 'Password1');

        await tester.tap(find.widgetWithText(PlanyButton, 'Connexion'));
        await tester.pump();

        await tester.runAsync(() async {
          while (viewModel.login.running) {
            await Future.delayed(const Duration(milliseconds: 50));
            await tester.pump();
          }
        });

        expect(fakeAuthRepository.token, 'fake_token');

        // Vérifie que la navigation a été appelée avec le bon chemin
        verify(() => goRouter.go('/')).called(1);
        // Vérifie que l'état de connexion a été mis à jour
        expect(fakeSessionManager.loggedIn, isTrue);
      });
    });
  });
}
