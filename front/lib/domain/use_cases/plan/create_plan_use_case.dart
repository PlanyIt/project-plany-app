import 'dart:io';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/utils/result.dart';

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
    required String userId,
  }) async {
    // 1. Upload images et créer steps
    final List<String> stepIds = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final imageFile = stepImages[i];

      String imageUrl = step.image;
      if (imageFile != null &&
          (imageUrl.isEmpty || !imageUrl.startsWith('http'))) {
        final uploadResult = await stepRepository.uploadImage(imageFile);
        if (uploadResult is! Ok<String>) {
          return Result.error(Exception('Erreur upload image étape ${i + 1}'));
        }
        imageUrl = uploadResult.value;
      }

      final stepToCreate = step.copyWith(image: imageUrl);
      final stepResult = await stepRepository.createStep(stepToCreate, userId);
      if (stepResult is! Ok<step_model.Step>) {
        return Result.error(Exception('Erreur création étape ${i + 1}'));
      }
      stepIds.add(stepResult.value.id!);
    }

    // 2. Créer le plan avec les stepIds
    final planToCreate = plan.copyWith(steps: stepIds);
    final planResult = await planRepository.createPlan(planToCreate);
    if (planResult is! Ok<Plan>) {
      return Result.error(Exception('Erreur création du plan'));
    }
    return planResult;
  }
}
