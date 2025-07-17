import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/session_manager.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';

import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../testing/fakes/repositories/fake_step_repository.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakePlanRepository planRepository;
  late FakeCategoryRepository categoryRepository;
  late FakeStepRepository stepRepository;
  late SessionManager sessionManager;

  setUp(() {
    authRepository = FakeAuthRepository();
    planRepository = FakePlanRepository();
    categoryRepository = FakeCategoryRepository();
    stepRepository = FakeStepRepository();

    sessionManager = SessionManager(
      authRepository: authRepository,
      planRepository: planRepository,
      categoryRepository: categoryRepository,
      stepRepository: stepRepository,
    );
  });

  group('SessionManager', () {
    test('login calls authRepository.login and clears caches on success',
        () async {
      // Remplir les caches pour vérifier qu'ils sont vidés
      await planRepository.createPlan(planRepository.plans.first);
      await categoryRepository.getCategoriesList();
      final stepsResult = await stepRepository.getStepsList('');
      final firstStep = stepsResult is Ok<List<Step>> &&
              stepsResult.value.isNotEmpty
          ? stepsResult.value.first
          : Step(id: 's', title: 't', description: 'd', order: 0, image: '');
      await stepRepository.createStep(firstStep);

      final result =
          await sessionManager.login(email: 'test@test.com', password: 'pass');
      expect(result, isA<Ok<void>>());
      expect(planRepository.plans, isEmpty);
      expect(categoryRepository.fakeCategories,
          isNotEmpty); // Les fake restent, mais le cache est vidé
      expect(
          await stepRepository.getStepsList(''), isA<Result<List<dynamic>>>());
    });

    test('logout calls authRepository.logout and clears caches on success',
        () async {
      await planRepository.createPlan(planRepository.plans.first);
      await categoryRepository.getCategoriesList();
      final stepsResult = await stepRepository.getStepsList('');
      final firstStep = stepsResult is Ok<List<Step>> &&
              stepsResult.value.isNotEmpty
          ? stepsResult.value.first
          : Step(id: 's', title: 't', description: 'd', order: 0, image: '');
      await stepRepository.createStep(firstStep);

      final result = await sessionManager.logout();
      expect(result, isA<Ok<void>>());
      expect(authRepository.token, isNull);
      expect(planRepository.plans, isEmpty);
      expect(categoryRepository.fakeCategories, isNotEmpty);
      expect(
          await stepRepository.getStepsList(''), isA<Result<List<dynamic>>>());
    });

    test('clearSpecificCaches clears only specified caches', () async {
      await planRepository.createPlan(planRepository.plans.first);
      await categoryRepository.getCategoriesList();

      await sessionManager.clearSpecificCaches(plans: true);
      expect(planRepository.plans, isEmpty);
      expect(categoryRepository.fakeCategories, isNotEmpty);
    });

    test('resetSession clears all caches', () async {
      await planRepository.createPlan(planRepository.plans.first);
      await categoryRepository.getCategoriesList();
      final stepsResult = await stepRepository.getStepsList('');
      final firstStep = stepsResult is Ok<List<Step>> &&
              stepsResult.value.isNotEmpty
          ? stepsResult.value.first
          : Step(id: 's', title: 't', description: 'd', order: 0, image: '');
      await stepRepository.createStep(firstStep);

      await sessionManager.resetSession();
      expect(planRepository.plans, isEmpty);
      expect(categoryRepository.fakeCategories, isNotEmpty);
      expect(
          await stepRepository.getStepsList(''), isA<Result<List<dynamic>>>());
    });
  });
}
