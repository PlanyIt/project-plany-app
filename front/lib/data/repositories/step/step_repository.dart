import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';

abstract class StepRepository {
  /// Récupère la liste des étapes d'un plan
  Future<Result<List<Step>>> getStepsList(String planId);
}
