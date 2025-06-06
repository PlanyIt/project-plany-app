import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/utils/result.dart';

/// Remote data source for [Category].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class CategoryRepositoryRemote implements CategoryRepository {
  CategoryRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Category>? _cachedData;

  @override
  Future<Result<List<Category>>> getCategoriesList() async {
    if (_cachedData == null) {
      // No cached data, request categories from API
      final result = await _apiClient.getCategories();
      if (result is Ok<List<Category>>) {
        // Store value if result Ok
        _cachedData = result.value;
      }
      return result;
    } else {
      // Return cached data if available
      return Result.ok(_cachedData!);
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    // Check if the category is already cached
    if (_cachedData != null) {
      try {
        final cachedCategory = _cachedData!.firstWhere(
          (category) => category.id == id.toString(),
          orElse: () => throw Exception('Category not found in cache'),
        );
        // Return the cached category
        return Result.ok(cachedCategory);
      } catch (e) {
        // Category not found in cache
      }
    }

    // Category not found in cache or cache is null
    // Request the category from API
    final result = await _apiClient.getCategoryById(id);
    if (result is Ok<Category>) {
      // Update cache with the new category
      _cachedData ??= [];
      _cachedData!.add(result.value);
    }
    return result;
  }
}
