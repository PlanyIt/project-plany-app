import 'package:front/data/repositories/categorie/category_repository.dart';
import 'package:front/data/services/api/api_client.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/core/utils/result.dart';
import 'package:front/core/utils/exceptions.dart';
import 'package:logging/logging.dart';

/// Remote data source for [Category].
/// Implements basic in-memory caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class CategoryRepositoryRemote implements CategoryRepository {
  CategoryRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('CategoryRepositoryRemote');
  List<Category>? _cachedData;

  /// Vide le cache manuellement (ex: après login/logout)
  void clearCache() {
    _cachedData = null;
  }

  @override
  Future<Result<List<Category>>> getCategoriesList() async {
    try {
      if (_cachedData == null) {
        _log.info('Fetching categories from API');
        final result = await _apiClient.getCategories();

        switch (result) {
          case Ok<List<Category>>():
            _cachedData = result.value;
            _log.info('Successfully cached ${result.value.length} categories');
            return result;
          case Error<List<Category>>():
            _log.warning('Failed to fetch categories: ${result.error}');
            return result;
        }
      } else {
        _log.info('Returning cached categories (${_cachedData!.length} items)');
        return Result.ok(_cachedData!);
      }
    } catch (e, stackTrace) {
      _log.severe('Unexpected error getting categories list', e, stackTrace);
      return Result.error(
        const UnknownException('Erreur lors de la récupération des catégories'),
      );
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      // Validate input
      if (id.isEmpty) {
        _log.warning('getCategoryById called with empty ID');
        return Result.error(
          const ValidationException('ID de catégorie requis'),
        );
      }

      // Check if the category is already cached
      if (_cachedData != null) {
        try {
          final cachedCategory = _cachedData!.firstWhere(
            (category) => category.id == id,
          );
          _log.info('Category found in cache: $id');
          return Result.ok(cachedCategory);
        } catch (_) {
          // Category not found in cache, fallback to API
          _log.info('Category not found in cache, fetching from API: $id');
        }
      }

      // Fetch from API
      _log.info('Fetching category from API: $id');
      final result = await _apiClient.getCategoryById(id);

      switch (result) {
        case Ok<Category>():
          _cachedData ??= [];

          // Update cache, replacing if exists
          final existingIndex = _cachedData!.indexWhere((cat) => cat.id == id);
          if (existingIndex != -1) {
            _cachedData![existingIndex] = result.value;
          } else {
            _cachedData!.add(result.value);
          }

          _log.info('Successfully fetched and cached category: $id');
          return result;

        case Error<Category>():
          _log.warning('Failed to fetch category $id: ${result.error}');
          return result;
      }
    } catch (e, stackTrace) {
      _log.severe(
          'Unexpected error getting category by ID: $id', e, stackTrace);
      return Result.error(
        const UnknownException(
            'Erreur lors de la récupération de la catégorie'),
      );
    }
  }
}
