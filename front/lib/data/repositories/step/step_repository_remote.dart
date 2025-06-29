import 'dart:io';

import 'package:front/data/repositories/step/step_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/data/services/imgur_service.dart';
import 'package:front/domain/models/step/step.dart';
import 'package:front/utils/result.dart';

class StepRepositoryRemote implements StepRepository {
  StepRepositoryRemote({
    required ApiClient apiClient,
    required ImgurService imgurService,
  })  : _apiClient = apiClient,
        _imgurService = imgurService;

  final ApiClient _apiClient;
  final ImgurService _imgurService;

  final Map<String, Step> _cachedSteps = {};

  void clearCache() {
    _cachedSteps.clear();
  }

  @override
  Future<Result<Step>> getStepById(String id) async {
    if (_cachedSteps.containsKey(id)) {
      return Result.ok(_cachedSteps[id]!);
    }

    final result = await _apiClient.getStepById(id);
    if (result is Ok<Step> && result.value.id != null) {
      _cachedSteps[result.value.id!] = result.value;
    }

    return result;
  }

  @override
  Future<Result<Step>> createStep(
    Step step,
    String userId,
  ) async {
    try {
      final result = await _apiClient.createStep(step, userId);

      print('📦 Résultat brut de createStep (depuis API client) : $result');

      if (result is Ok<Step>) {
        final created = result.value;
        print('✅ Step créé avec l\'ID: ${created.id}');

        // Tu peux ajouter un cache si besoin, mais tu n’as pas l'objet complet ici
        return Result.ok(created);
      } else if (result is Error<Step>) {
        print('❌ Erreur retournée par API client: ${result.error}');
        return Result.error(result.error);
      } else {
        print('❌ Type de résultat inattendu: $result');
        return Result.error(Exception('Unexpected result type from API'));
      }
    } catch (e, stacktrace) {
      print('🔥 Exception dans createStep: $e');
      print(stacktrace);
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
