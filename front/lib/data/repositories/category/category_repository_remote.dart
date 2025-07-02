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
    try {
      final result = await _apiClient.getCategories();
      switch (result) {
        case Ok<List<CategoryApiModel>>():
          _cachedCategories = result.value
              .map((category) => Category(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    color: category.color,
                  ))
              .toList();
          return Result.ok(_cachedCategories!);
        case Error<List<CategoryApiModel>>():
          return Result.error(result.error);
      }
    } on Exception catch (error) {
      return Result.error(error);
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
}
