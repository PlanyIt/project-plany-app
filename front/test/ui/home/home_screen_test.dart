import 'package:flutter_test/flutter_test.dart';
import 'package:front/routing/routes.dart';
import 'package:front/ui/core/ui/button/plany_button.dart';
import 'package:front/ui/core/ui/logo/plany_logo.dart';
import 'package:front/ui/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../testing/fakes/app.dart';
import '../../../testing/mocks.dart';

void main() {
  group('HomeScreen tests', () {
    late MockGoRouter goRouter;

    setUp(() {
      goRouter = MockGoRouter();
      when(() => goRouter.push(any())).thenAnswer((_) => Future.value());
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        const HomeScreen(),
        goRouter: goRouter,
      );
    }

    testWidgets('should display logo and buttons', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(PlanyLogo), findsOneWidget);
        expect(
            find.widgetWithText(PlanyButton, 'Se connecter'), findsOneWidget);
        expect(find.widgetWithText(PlanyButton, "S'inscrire"), findsOneWidget);
      });
    });

    testWidgets('should navigate to login when tapping login button',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        await tester.tap(find.widgetWithText(PlanyButton, 'Se connecter'));
        await tester.pump();
        verify(() => goRouter.push(Routes.login)).called(1);
      });
    });

    testWidgets('should navigate to register when tapping register button',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        await tester.tap(find.widgetWithText(PlanyButton, "S'inscrire"));
        await tester.pump();
        verify(() => goRouter.push(Routes.register)).called(1);
      });
    });
  });
}
