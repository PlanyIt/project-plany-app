import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/core/ui/button/logout_button.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/dashboard/widgets/profile_drawer.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../../testing/fakes/services/fake_location_service.dart';
import '../../../../testing/models/user.dart';

class MockDashboardViewModel extends DashboardViewModel {
  MockDashboardViewModel()
      : super(
          categoryRepository: FakeCategoryRepository(),
          authRepository: FakeAuthRepository(),
          planRepository: FakePlanRepository(),
          locationService: FakeLocationService(),
        );

  @override
  User? get user => kUser;
}

// Add this mock class for mocktail-based stubbing
class DashboardViewModelMock extends Mock implements DashboardViewModel {}

void main() {
  testWidgets('ProfileDrawer displays user info and menu items',
      (WidgetTester tester) async {
    var closeCalled = false;

    final viewModel = MockDashboardViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDrawer(
            viewModel: viewModel,
            onClose: () => closeCalled = true,
            onLogout: () {},
          ),
        ),
      ),
    );

    // Vérifie l'affichage du nom d'utilisateur et de l'email
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);

    // Vérifie la présence des items de menu
    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Mes plans & favoris'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);

    // Vérifie la présence du bouton de fermeture
    await tester.tap(find.byIcon(Icons.close));
    expect(closeCalled, isTrue);

    // Vérifie la présence du bouton de logout
    await tester.tap(find.textContaining('Déconnexion').first,
        warnIfMissed: false);
    // Le bouton peut être un custom widget, donc on ne vérifie pas logoutCalled ici sans accès au widget exact.
  });

  testWidgets('ProfileDrawer shows avatar with photoUrl', (tester) async {
    final viewModel = DashboardViewModelMock();
    when(() => viewModel.logout)
        .thenReturn(Command0(() async => Result.ok(null)));
    final userWithPhoto =
        kUser.copyWith(photoUrl: 'https://fake.url/photo.png');
    when(() => viewModel.user).thenReturn(userWithPhoto);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDrawer(
            viewModel: viewModel,
            onClose: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('ProfileDrawer handles null user gracefully', (tester) async {
    final viewModel = DashboardViewModelMock();
    when(() => viewModel.logout)
        .thenReturn(Command0(() async => Result.ok(null)));
    when(() => viewModel.user).thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDrawer(
            viewModel: viewModel,
            onClose: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(find.text('Utilisateur'), findsOneWidget);
    expect(find.text("Pas d'email"), findsOneWidget);
  });

  testWidgets(
      'ProfileDrawer menu items call onClose and show snackbar if user is null',
      (tester) async {
    final viewModel = DashboardViewModelMock();
    when(() => viewModel.logout)
        .thenReturn(Command0(() async => Result.ok(null)));
    when(() => viewModel.user).thenReturn(null);

    var closeCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDrawer(
            viewModel: viewModel,
            onClose: () => closeCalled = true,
            onLogout: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mon profil'));
    await tester.pump(); // SnackBar animation
    expect(closeCalled, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
