import 'package:flutter_test/flutter_test.dart';

import 'package:front/ui/auth/register/register_screen.dart';
import 'package:front/ui/auth/register/view_models/register_viewmodel.dart';
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
  group('RegisterScreen tests', () {
    late RegisterViewModel viewModel;
    late MockGoRouter goRouter;
    late FakeAuthRepository fakeAuthRepository;
    late FakePlanRepository fakePlanRepository;
    late FakeCategoryRepository fakeCategoryRepository;
    late FakeSessionManager fakeSessionManager;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      fakePlanRepository = FakePlanRepository();
      fakeCategoryRepository = FakeCategoryRepository();
      fakeSessionManager = FakeSessionManager(
        authRepository: fakeAuthRepository,
        planRepository: fakePlanRepository,
        categoryRepository: fakeCategoryRepository,
        stepRepository: FakeStepRepository(),
      );

      viewModel = RegisterViewModel(sessionManager: fakeSessionManager);
      goRouter = MockGoRouter();
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        RegisterScreen(viewModel: viewModel),
        goRouter: goRouter,
      );
    }

    testWidgets('should load screen', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(RegisterScreen), findsOneWidget);
      });
    });

    testWidgets('should perform register', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        await tester.enterText(
            find.byType(CustomTextField).at(0), 'email@email.com');
        await tester.enterText(find.byType(CustomTextField).at(1), 'username');
        await tester.enterText(find.byType(CustomTextField).at(2), 'Password1');

        await tester.tap(find.widgetWithText(PlanyButton, 'Inscription'));
        await tester.pump();

        await tester.runAsync(() async {
          while (viewModel.register.running) {
            await Future.delayed(const Duration(milliseconds: 50));
            await tester.pump();
          }
        });

        expect(fakeAuthRepository.token, 'fake_token');
        verify(() => goRouter.go('/')).called(1);
      });
    });
  });
}
