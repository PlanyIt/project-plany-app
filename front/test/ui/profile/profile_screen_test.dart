import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/auth/auth_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/user/user_repository.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/profil/profile_screen.dart';
import 'package:front/ui/profil/widgets/content/my_plans_section.dart';
import 'package:front/ui/profil/widgets/header/profile_header.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';

import '../../../testing/fakes/app.dart';
import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../testing/fakes/repositories/fake_user_repository.dart';

void main() {
  group('ProfileScreen tests', () {
    late FakeAuthRepository fakeAuthRepository;
    late FakePlanRepository fakePlanRepository;
    late FakeUserRepository fakeUserRepository;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      fakePlanRepository = FakePlanRepository();
      fakeUserRepository = FakeUserRepository();

      fakeAuthRepository.token = 'fake_token';
      fakeAuthRepository.updateCurrentUser(User(
        id: 'user1',
        username: 'TestUser',
        email: 'test@email.com',
      ));
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthRepository>.value(
                value: fakeAuthRepository),
            Provider<PlanRepository>.value(value: fakePlanRepository),
            Provider<UserRepository>.value(value: fakeUserRepository),
          ],
          child: const ProfileScreen(),
        ),
      );
    }

    testWidgets('should display loading then profile content',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.byType(ProfileHeader), findsOneWidget);
        expect(find.byType(MyPlansSection), findsOneWidget);
      });
    });
  });
}
