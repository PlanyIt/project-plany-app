import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../../testing/fakes/services/fake_location_service.dart';

void main() {
  late DashboardViewModel viewModel;
  late FakeCategoryRepository categoryRepo;

  setUp(() async {
    categoryRepo = FakeCategoryRepository();
    categoryRepo.clearCache();
    await categoryRepo.getCategoriesList();

    viewModel = DashboardViewModel(
      categoryRepository: categoryRepo,
      authRepository: FakeAuthRepository(),
      planRepository: FakePlanRepository(),
      locationService: FakeLocationService(),
    );
  });

  test('Initial state is correct', () async {
    await viewModel.load.execute();
    expect(viewModel.categories, isEmpty);
    expect(viewModel.plans, isEmpty);
    expect(viewModel.hasLoadedData, isFalse);
    expect(viewModel.user, isNotNull);
  });

  test('load command loads categories and plans', () async {
    await Future.delayed(Duration(milliseconds: 10));
    await viewModel.load.execute();
    expect(viewModel.categories, isNotEmpty);
    expect(viewModel.plans, isNotEmpty);
    expect(viewModel.hasLoadedData, isTrue);
  });

  test('logout command completes without error', () async {
    await viewModel.logout.execute();
    expect(viewModel.hasError, isFalse);
  });

  test('clearError resets error state', () {
    viewModel.clearError();
    expect(viewModel.hasError, isFalse);
    expect(viewModel.errorMessage, isNull);
  });

  test('getCategoryById returns Ok for existing id', () async {
    await Future.delayed(Duration(milliseconds: 10));
    await viewModel.load.execute();
    final category = viewModel.categories.first;
    final result = await viewModel.getCategoryById(category.id);
    expect(result, isA<Ok<Category>>());
    expect((result as Ok<Category>).value.id, category.id);
  });

  test('getCategoryById returns Error for unknown id', () async {
    final result = await viewModel.getCategoryById('unknown');
    expect(result, isA<Error>());
  });
}
