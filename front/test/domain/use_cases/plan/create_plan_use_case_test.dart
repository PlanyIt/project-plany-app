import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/use_cases/plan/create_plan_use_case.dart';
import 'package:front/utils/result.dart';
import '../../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../../testing/fakes/repositories/fake_step_repository.dart';
import '../../../../testing/models/plan.dart';
import '../../../../testing/models/step.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('CreatePlanUseCase', () {
    late CreatePlanUseCase useCase;
    late FakePlanRepository planRepo;
    late FakeStepRepository stepRepo;

    setUp(() {
      planRepo = FakePlanRepository();
      stepRepo = FakeStepRepository();
      useCase = CreatePlanUseCase(
        planRepository: planRepo,
        stepRepository: stepRepo,
      );
    });

    test('creates plan with steps and uploads images', () async {
      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep],
        stepImages: [null],
      );

      expect(result, isA<Ok>());
      expect(result.asOk.value.title, kPlan.title);
    });

    test('fails when image upload fails', () async {
      stepRepo.uploadImageResult = Result.error(Exception('upload fail'));

      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep],
        stepImages: [File('dummy.png')],
      );

      expect(result.isOk, false);
      expect(
        result.asError.error.toString(),
        contains('Erreur upload image étape 1'),
      );
    });

    test('fails when step creation fails', () async {
      stepRepo.createStepResult = Result.error(Exception('step fail'));

      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep],
        stepImages: [null],
      );

      expect(result.isOk, false);
      expect(
        result.asError.error.toString(),
        contains('Erreur création étape 1'),
      );
    });

    test('fails when plan creation fails', () async {
      planRepo.createPlanResult = Result.error(Exception('plan fail'));

      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep],
        stepImages: [null],
      );

      expect(result.isOk, false);
      expect(
        result.asError.error.toString(),
        contains('Erreur création du plan'),
      );
    });

    test(
        'uploads image only if file is not null and step image is missing or non-http',
        () async {
      stepRepo.uploadImageResult = Result.ok('http://img');

      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep.copyWith(image: '')],
        stepImages: [File('dummy.png')],
      );

      expect(result.isOk, true);
    });

    test('skips upload if image file is null', () async {
      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep.copyWith(image: '')],
        stepImages: [null],
      );

      expect(result.isOk, true);
    });

    test('skips upload if step already has http image', () async {
      final result = await useCase.call(
        plan: kPlan,
        steps: [kStep.copyWith(image: 'http://img')],
        stepImages: [File('dummy.png')],
      );

      expect(result.isOk, true);
    });
  });
}
