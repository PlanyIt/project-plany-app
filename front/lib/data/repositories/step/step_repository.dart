import 'dart:io';

import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';

abstract class StepRepository {
  /// Récupère la liste des étapes d'un plan
  Future<Result<List<Step>>> getStepsList(String planId);

  /// Creates a new [Step].
  Future<Result<Step>> createStep(Step step);

  /// Uploads an image for a [Step].
  Future<Result<String>> uploadImage(File imageFile);

  /// Clears the cache of steps.
  Future<void> clearCache();
}
