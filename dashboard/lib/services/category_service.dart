import 'package:dashboard/models/category.dart';
import 'package:dashboard/services/api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    final response = await _apiService.get('/api/categories');
    return (response as List).map((data) => Category.fromJson(data)).toList();
  }

  Future<Category> getCategoryById(String id) async {
    final response = await _apiService.get('/api/categories/$id');
    return Category.fromJson(response);
  }

  Future<Category> createCategory(Category category) async {
    final response =
        await _apiService.post('/api/categories', category.toJson());
    return Category.fromJson(response);
  }

  Future<Category> updateCategory(String id, Category category) async {
    final response =
        await _apiService.put('/api/categories/$id', category.toJson());
    return Category.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _apiService.delete('/api/categories/$id');
  }
}
