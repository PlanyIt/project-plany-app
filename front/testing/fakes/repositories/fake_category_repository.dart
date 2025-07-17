import 'package:front/data/repositories/category/category_repository.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/utils/result.dart';

class FakeCategoryRepository extends CategoryRepository {
  List<Category>? _cachedCategories;

  final _fakeCategories = [
    Category(id: '1', name: 'Cat1', icon: 'icon1', color: 'FF0000'),
    Category(id: '2', name: 'Cat2', icon: 'icon2', color: '00FF00'),
    Category(id: '3', name: 'Cat3', icon: 'icon3', color: '0000FF'),
  ];

  List<Category> get fakeCategories => _fakeCategories;

  @override
  Future<Result<List<Category>>> getCategoriesList() async {
    _cachedCategories = List.from(_fakeCategories);
    return Result.ok(_cachedCategories!);
  }

  @override
  Future<Result<Category>> getCategory(String id) async {
    try {
      final category = _fakeCategories.firstWhere((cat) => cat.id == id);
      return Result.ok(category);
    } catch (e) {
      return Result.error(Exception('Category not found'));
    }
  }

  void clearCache() {
    _cachedCategories = null;
  }
}
