import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/plan/plan_repository.dart';
import '../../../data/repositories/step/step_repository.dart';
import '../../../utils/result.dart';
import '../../models/plan/plan.dart';
import '../../models/step/step.dart' as step_model;

class CreatePlanUseCase {
  final PlanRepository planRepository;
  final StepRepository stepRepository;

  CreatePlanUseCase({
    required this.planRepository,
    required this.stepRepository,
  });

  /// [plan] : Plan à créer (steps doit contenir les StepCard)
  /// [steps] : Liste des steps à créer (avec image locale)
  /// [userId] : Id de l'utilisateur
  /// [stepImages] : Liste des fichiers images pour chaque step (même ordre que steps)
  Future<Result<Plan>> call({
    required Plan plan,
    required List<step_model.Step> steps,
    required List<File?> stepImages,
  }) async {
    // 1. Upload images et créer steps
    final createdSteps = <step_model.Step>[];
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final imageFile = stepImages[i];

      var imageUrl = step.image;
      if (imageFile != null &&
          (imageUrl.isEmpty || !imageUrl.startsWith('http'))) {
        final uploadResult = await stepRepository.uploadImage(imageFile);
        if (uploadResult is! Ok<String>) {
          return Result.error(Exception('Erreur upload image étape ${i + 1}'));
        }
        imageUrl = uploadResult.value;
      }

      final stepToCreate = step.copyWith(image: imageUrl);
      final stepResult = await stepRepository.createStep(stepToCreate);
      if (stepResult is! Ok<step_model.Step>) {
        return Result.error(Exception('Erreur création étape ${i + 1}'));
      }
      createdSteps.add(stepResult.value);
    }

    // 2. Créer le plan avec les stepIds
    final planToCreate = plan.copyWith(steps: createdSteps);
    final planResult = await planRepository.createPlan(planToCreate);
    if (planResult is! Ok<Plan>) {
      if (kDebugMode) {
        print('❌ Failed to create plan: $planResult');
      }
      return Result.error(Exception('Erreur création du plan'));
    }

    return planResult;
  }
}
