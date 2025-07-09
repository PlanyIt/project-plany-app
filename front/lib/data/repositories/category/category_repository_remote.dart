import '../../../domain/models/category/category.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/api/model/category/category_api_model.dart';
import 'category_repository.dart';

/// Remote data source for [Category].
/// Implements basic in-memory caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class CategoryRepositoryRemote implements CategoryRepository {
  CategoryRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  List<Category>? _cachedCategories;

  @override
  Future<Result<List<Category>>> getCategoriesList() async {
    if (_cachedCategories == null) {
      // No cached data, request categories
      final result = await _apiClient.getCategories();
      if (result is Ok<List<CategoryApiModel>>) {
        // Store value if result Ok and map to Category
        final apiModels = result.value;
        _cachedCategories = apiModels
            .map((apiModel) => Category(
                  id: apiModel.id,
                  name: apiModel.name,
                  icon: apiModel.icon,
                  color: apiModel.color,
                ))
            .toList();
        return Result.ok(_cachedCategories!);
      }
      return Result.error((result as Error).error);
    } else {
      // Return cached data if available
      return Result.ok(_cachedCategories!);
    }
  }

  @override
  Future<Result<Category>> getCategory(String id) async {
    try {
      final resultCategory = await _apiClient.getCategory(id);
      switch (resultCategory) {
        case Error<CategoryApiModel>():
          return Result.error(resultCategory.error);
        case Ok<CategoryApiModel>():
      }

      return Result.ok(
        Category(
          id: resultCategory.value.id,
          name: resultCategory.value.name,
          icon: resultCategory.value.icon,
          color: resultCategory.value.color,
        ),
      );
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  void clearCache() {
    _cachedCategories = null;
  }
}
