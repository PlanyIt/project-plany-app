import 'dart:io';

import 'package:latlong2/latlong.dart';

import '../../../domain/models/step/step.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/step/step_api_model.dart';
import '../../services/imgur_service.dart';
import 'step_repository.dart';

/// Remote data source for [Step].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class StepRepositoryRemote implements StepRepository {
  StepRepositoryRemote({
    required ApiClient apiClient,
    required ImgurService imgurService,
  })  : _apiClient = apiClient,
        _imgurService = imgurService;

  final ApiClient _apiClient;
  final ImgurService _imgurService;

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

  @override
  Future<Result<Step>> createStep(
    Step step,
    String userId,
  ) async {
    try {
      final result = await _apiClient.createStep(step, userId);

      if (result is Ok<Step>) {
        final created = result.value;
        return Result.ok(created);
      } else if (result is Error<Step>) {
        return Result.error(result.error);
      } else {
        return Result.error(Exception('Unexpected result type from API'));
      }
    } catch (e, _) {
      return Result.error(Exception('createStep failed: $e'));
    }
  }

  @override
  Future<Result<String>> uploadImage(File imageFile) async {
    try {
      final imageUrl = await _imgurService.uploadImage(imageFile);
      return Result.ok(imageUrl);
    } catch (e) {
      return Result.error(Exception('Failed to upload image: $e'));
    }
  }
}
