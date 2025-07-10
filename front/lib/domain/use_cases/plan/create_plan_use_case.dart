import 'dart:io';

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

  /// [plan] : Plan à créer (steps doit contenir les StepCard ou objets intermédiaires)
  /// [steps] : Liste des steps à créer (avec image locale)
  /// [userId] : Id de l'utilisateur
  /// [stepImages] : Liste des fichiers images pour chaque step (même ordre que steps)
  Future<Result<Plan>> call({
    required Plan plan,
    required List<step_model.Step> steps,
    required List<File?> stepImages,
    required String user,
  }) async {
    // 1. Upload images et créer steps
    final createdSteps = <step_model.Step>[]; // Renamed to avoid collision
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
      final stepResult = await stepRepository.createStep(stepToCreate, user);
      if (stepResult is! Ok<step_model.Step>) {
        return Result.error(Exception('Erreur création étape ${i + 1}'));
      }
      createdSteps.add(stepResult.value);
    }

    print('✅ Created ${createdSteps.length} steps'); // Debug

    // 2. Créer le plan avec les stepIds
    final planToCreate = plan.copyWith(steps: createdSteps);
    final planResult = await planRepository.createPlan(planToCreate);
    if (planResult is! Ok<Plan>) {
      return Result.error(Exception('Erreur création du plan'));
    }
    return planResult;
  }
}
