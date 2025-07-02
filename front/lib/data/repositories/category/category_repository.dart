import '../../../domain/models/category/category.dart';
import '../../../utils/result.dart';

abstract class CategoryRepository {
  /// Returns the list of [Category].
  Future<Result<List<Category>>> getCategoriesList();

  /// Returns the [Category] with the given [id].
  Future<Result<Category>> getCategory(String id);
}
