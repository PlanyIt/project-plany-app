import 'dart:io';

import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';

class FakeStepRepository extends StepRepository {
  final List<Step> _steps = [];
  int _idCounter = 0;

  /// Permet de forcer le résultat de uploadImage dans les tests.
  Result<String>? uploadImageResult;

  /// Permet de forcer le résultat de createStep dans les tests.
  Result<Step>? createStepResult;

  @override
  Future<Result<List<Step>>> getStepsList(String planId) async {
    return Result.ok(List<Step>.from(_steps));
  }

  @override
  Future<Result<Step>> createStep(Step step) async {
    if (createStepResult != null) {
      return createStepResult!;
    }
    final newStep = step.copyWith(
      id: 'step_${_idCounter++}',
    );
    _steps.add(newStep);
    return Result.ok(newStep);
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    if (uploadImageResult != null) {
      return uploadImageResult!;
    }
    return Result.ok(
        'https://fake-storage.com/steps/${imageFile.path.split('/').last}');
  }

  Future<void> clearCache() async {
    _steps.clear();
  }
}
