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
  group('CreatePlanUseCase tests', () {
    late CreatePlanUseCase useCase;

    setUp(() {
      useCase = CreatePlanUseCase(
        planRepository: FakePlanRepository(),
        stepRepository: FakeStepRepository(),
      );
    });

    test('should create plan with steps and upload images', () async {
      final steps = [kStep];
      final images = <File?>[null];

      final result = await useCase.call(
        plan: kPlan,
        steps: steps,
        stepImages: images,
      );

      expect(result, isA<Ok>());
      expect(result.asOk.value.title, kPlan.title);
    });
  });
}
