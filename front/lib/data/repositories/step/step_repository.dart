import 'dart:io';

import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';

abstract class StepRepository {
  /// Returns the list of [Step] for a given [id].
  Future<Result<Step>> getStepById(String id);

  /// Creates a new [Step].
  Future<Result<Step>> createStep(Step step, String userId);

  /// Uploads an image for a [Step].
  Future<Result<String>> uploadImage(File imageFile);
}
