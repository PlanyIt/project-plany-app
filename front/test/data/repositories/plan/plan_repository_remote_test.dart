import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/plan/plan_repository_remote.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/models/plan.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('PlanRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late PlanRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      repository = PlanRepositoryRemote(apiClient: apiClient);
    });

    test('get plans list returns success', () async {
      final result = await repository.getPlanList();
      expect(result, isA<Ok>());

      final plans = result.asOk.value;
      expect(plans.length, greaterThan(0));

      expect(apiClient.requestCount, 1);
    });

    test('create plan returns success', () async {
      final plan = kPlan.copyWith(title: 'New Plan');
      final result = await repository.createPlan(plan);
      expect(result, isA<Ok>());
    });

    test('add to favorites returns success', () async {
      final result = await repository.addToFavorites('plan1');
      expect(result, isA<Ok>());
    });

    test('remove from favorites returns success', () async {
      final result = await repository.removeFromFavorites('plan1');
      expect(result, isA<Ok>());
    });

    test('get plans by user returns success', () async {
      final result = await repository.getPlansByUser('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.length, greaterThan(0));
    });

    test('get favorites by user returns success', () async {
      final result = await repository.getFavoritesByUser('user1');
      expect(result, isA<Ok>());
      expect(result.asOk.value.length, greaterThan(0));
    });

    test('get plan by id returns success', () async {
      final result = await repository.getPlan('plan1');
      expect(result, isA<Ok>());
    });

    test('delete plan returns success', () async {
      final result = await repository.deletePlan('plan1');
      expect(result, isA<Ok>());
    });

    test('clear cache works without error', () async {
      await repository.clearCache();
      expect(repository.cachedData, isNull);
    });
  });
}
