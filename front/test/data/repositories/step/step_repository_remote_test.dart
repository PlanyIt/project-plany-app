import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/step/step_repository_remote.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/fakes/services/fake_imgur_service.dart';
import '../../../../testing/models/step.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('StepRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late FakeImgurService imgurService;
    late StepRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      imgurService = FakeImgurService();
      repository = StepRepositoryRemote(
        apiClient: apiClient,
        imgurService: imgurService,
      );
    });

    test('get steps list returns success', () async {
      final result = await repository.getStepsList('plan1');
      expect(result, isA<Ok>());

      final steps = result.asOk.value;
      expect(steps.length, greaterThan(0));

      expect(apiClient.requestCount, 1);
    });

    test('create step returns success', () async {
      final result = await repository.createStep(kStep);
      expect(result, isA<Ok>());
    });

    test('upload image returns fake url', () async {
      final file = File('test.jpg');
      final result = await repository.uploadImage(file);
      expect(result, isA<Ok>());
      expect(result.asOk.value, startsWith('https://fake-storage.com/'));
    });

    test('clear cache works without error', () async {
      await repository.clearCache();
      // Tu peux vérifier qu'aucune exception n'est levée
    });
  });
}
