import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/detail_plan/plan_details_screen.dart';
import 'package:front/ui/detail_plan/view_models/detail/favorite_viewmodel.dart';
import 'package:front/ui/detail_plan/view_models/detail/follow_user_viewmodel.dart';
import 'package:front/ui/detail_plan/view_models/detail/plan_details_viewmodel.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_comment_repository.dart';
import '../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../testing/fakes/repositories/fake_user_repository.dart';
import '../../../testing/fakes/services/fake_location_service.dart';

void main() {
  group('PlanDetailsScreen tests', () {
    late PlanDetailsViewModel planVM;
    late FavoriteViewModel favoriteVM;
    late FollowUserViewModel followVM;
    late FakePlanRepository fakePlanRepository;
    late FakeAuthRepository fakeAuthRepository;
    late FakeUserRepository fakeUserRepository;
    late FakeLocationService fakeLocationService;

    setUp(() {
      fakePlanRepository = FakePlanRepository();
      fakeAuthRepository = FakeAuthRepository();
      fakeLocationService = FakeLocationService();
      fakeUserRepository = FakeUserRepository();

      // Ajouter un plan factice dans le repo
      final plan = Plan(
        id: '1',
        title: 'Fake Plan',
        description: 'Description',
        category: null,
        user: User(id: 'user1', username: 'user1', email: 'email@email.com'),
        steps: [],
      );
      fakePlanRepository.createPlan(plan);

      planVM = PlanDetailsViewModel(
        planRepository: fakePlanRepository,
        locationService: fakeLocationService,
        authRepository: fakeAuthRepository,
        userRepository: fakeUserRepository,
        commentRepository: FakeCommentRepository(),
        planId: '1',
      );

      favoriteVM = FavoriteViewModel(
        fakePlanRepository,
        fakeAuthRepository,
      );

      followVM = FollowUserViewModel(
        fakeUserRepository,
        fakeAuthRepository,
      );
    });

    testWidgets('should show loader then plan details',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: PlanDetailsScreen(
              planId: '1',
              planVM: planVM,
              favoriteVM: favoriteVM,
              followVM: followVM,
            ),
          ),
        );

        // Vérifie le loader au départ
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Après chargement, plus de loader, plan affiché
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(PlanDetailsScreen), findsOneWidget);
      });
    });
  });
}
