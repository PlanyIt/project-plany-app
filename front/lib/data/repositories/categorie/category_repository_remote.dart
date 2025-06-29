import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/utils/result.dart';

/// Remote data source for [Category].
/// Implements basic in-memory caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class CategoryRepositoryRemote implements CategoryRepository {
  CategoryRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  List<Category>? _cachedData;

  /// Vide le cache manuellement (ex: après login/logout)
  void clearCache() {
    _cachedData = null;
  }

  @override
  Future<Result<List<Category>>> getCategoriesList() async {
    if (_cachedData == null) {
      final result = await _apiClient.getCategories();
      if (result is Ok<List<Category>>) {
        _cachedData = result.value;
      }
      return result;
    } else {
      return Result.ok(_cachedData!);
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    // Check if the category is already cached
    if (_cachedData != null) {
      try {
        final cachedCategory = _cachedData!.firstWhere(
          (category) => category.id == id,
          orElse: () => throw Exception('Category not found in cache'),
        );
        return Result.ok(cachedCategory);
      } catch (_) {
        // Category not found in cache, fallback to API
      }
    }

    // Fetch from API
    final result = await _apiClient.getCategoryById(id);
    if (result is Ok<Category>) {
      _cachedData ??= [];
      _cachedData!.add(result.value);
    }
    return result;
  }
}
