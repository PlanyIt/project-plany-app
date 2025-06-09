import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/step.dart';
import 'package:front/utils/result.dart';

/// Remote data source for [Step].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class StepRepositoryRemote implements StepRepository {
  StepRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Step>? _cachedData;

  @override
  Future<Result<Step>> getStepById(String id) async {
    if (_cachedData != null) {
      try {
        final cachedStep = _cachedData!.firstWhere(
          (step) => step.id == id.toString(),
          orElse: () => throw Exception('Step not found in cache'),
        );
        // Return the cached step
        return Result.ok(cachedStep);
      } catch (e) {
        // Step not found in cache
      }
    }

    // Step not found in cache or cache is null
    // Request the Step from API
    final result = await _apiClient.getStepById(id);
    if (result is Ok<Step>) {
      // Update cache with the new step
      _cachedData ??= [];
      _cachedData!.add(result.value);
    }
    return result;
  }
}
