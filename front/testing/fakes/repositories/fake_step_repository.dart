import 'dart:io';

import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';

class FakeStepRepository extends StepRepository {
  final List<Step> _steps = [];
  int _idCounter = 0;

  @override
  Future<Result<List<Step>>> getStepsList(String planId) async {
    return Result.ok(List<Step>.from(_steps));
  }

  @override
  Future<Result<Step>> createStep(Step step) async {
    final newStep = step.copyWith(
      id: 'step_${_idCounter++}',
    );
    _steps.add(newStep);
    return Result.ok(newStep);
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    return Result.ok(
        'https://fake-storage.com/steps/${imageFile.path.split('/').last}');
  }

  @override
  Future<void> clearCache() async {
    _steps.clear();
  }
}
