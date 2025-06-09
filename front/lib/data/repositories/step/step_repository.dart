import 'package:front/domain/models/step.dart';
import 'package:front/utils/result.dart';

abstract class StepRepository {
  /// Returns the list of [Step] for a given [id].
  Future<Result<Step>> getStepById(String id);
}
