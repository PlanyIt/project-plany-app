import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:dashboard/models/category.dart';
import 'package:dashboard/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedCategories = await _categoryService.getCategories();
      _categories = fetchedCategories;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCategoryById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final category = await _categoryService.getCategoryById(id);
      _selectedCategory = category;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createCategory(Category category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final createdCategory = await _categoryService.createCategory(category);
      _categories.add(createdCategory);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(String id, Category category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedCategory =
          await _categoryService.updateCategory(id, category);

      // Update the category in the list
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }

      if (_selectedCategory?.id == id) {
        _selectedCategory = updatedCategory;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _categoryService.deleteCategory(id);

      // Remove the category from the list
      _categories.removeWhere((c) => c.id == id);

      if (_selectedCategory?.id == id) {
        _selectedCategory = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
