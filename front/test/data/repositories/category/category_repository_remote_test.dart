import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/category/category_repository_remote.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';
import '../../../../testing/utils/result.dart';

void main() {
  group('CategoryRepositoryRemote tests', () {
    late FakeApiClient apiClient;
    late CategoryRepositoryRemote repository;

    setUp(() {
      apiClient = FakeApiClient();
      repository = CategoryRepositoryRemote(apiClient: apiClient);
    });

    test('get categories list returns success', () async {
      final result = await repository.getCategoriesList();
      expect(result, isA<Ok>());

      final categories = result.asOk.value;
      expect(categories.length, 3);
      expect(categories.first.name, 'Cat1');

      expect(apiClient.requestCount, 1);
    });

    test('get categories uses cache on second call', () async {
      await repository.getCategoriesList();
      await repository.getCategoriesList();

      // Le cache est utilisé, pas d'appel supplémentaire
      expect(apiClient.requestCount, 1);
    });

    test('clear cache allows new API call', () async {
      await repository.getCategoriesList();
      repository.clearCache();
      await repository.getCategoriesList();

      // Après clearCache, l'API est appelée à nouveau
      expect(apiClient.requestCount, 2);
    });

    test('get category returns success', () async {
      final result = await repository.getCategory('1');
      expect(result, isA<Ok>());

      final category = result.asOk.value;
      expect(category.name, 'NAME');
    });
  });
}
