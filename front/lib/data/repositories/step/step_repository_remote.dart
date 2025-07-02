import 'package:latlong2/latlong.dart';

import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/step/step_api_model.dart';
import 'step_repository.dart';

/// Remote data source for [Step].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class StepRepositoryRemote implements StepRepository {
  StepRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  final Map<String, List<Step>> _cachedData = {};

  @override
  Future<Result<List<Step>>> getStepsList(String planId) async {
    if (_cachedData.containsKey(planId)) {
      return Result.ok(List<Step>.from(_cachedData[planId]!));
    }

    try {
      final result = await _apiClient.getStepsByPlan(planId);
      switch (result) {
        case Ok<List<StepApiModel>>():
          final stepsApi = result.value;
          final steps = stepsApi
              .map((stepApi) => Step(
                    title: stepApi.title,
                    description: stepApi.description,
                    position:
                        LatLng(stepApi.latitude ?? 0, stepApi.longitude ?? 0),
                    order: stepApi.order,
                    image: stepApi.image,
                    duration: stepApi.duration,
                    cost: stepApi.cost,
                  ))
              .toList();
          _cachedData[planId] = steps;
          return Result.ok(steps);
        case Error<List<StepApiModel>>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
