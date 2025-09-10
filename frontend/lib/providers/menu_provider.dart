import 'package:flutter/foundation.dart';
import '../models/menu/category.dart';
import '../models/menu/menu_item.dart';
import '../models/menu/create_category_input.dart';
import '../models/menu/create_menu_item_input.dart';
import '../models/menu/update_menu_item_input.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService = MenuService.instance;

  List<ItemsCategory> _categories = [];
  List<MenuItem> _items = [];
  MenuItem? _currentItem;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ItemsCategory> get categories => _categories;
  List<MenuItem> get items => _items;
  MenuItem? get currentItem => _currentItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _setError(null);
  }

  // Load categories for a restaurant
  Future<bool> loadCategories(int restaurantId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _menuService.getCategories(restaurantId);
      
      if (response.success && response.data != null) {
        _categories = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load categories');
        return false;
      }
    } catch (e) {
      _setError('Failed to load categories: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load items for a category
  Future<bool> loadItems(int categoryId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _menuService.getItems(categoryId);
      
      if (response.success && response.data != null) {
        _items = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load items');
        return false;
      }
    } catch (e) {
      _setError('Failed to load items: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load a specific item
  Future<bool> loadItem(int itemId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _menuService.getItem(itemId);
      
      if (response.success && response.data != null) {
        _currentItem = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to load item');
        return false;
      }
    } catch (e) {
      _setError('Failed to load item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new category
  Future<bool> createCategory({
    required String name,
    required int restaurantId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final input = CreateCategoryInput(
        name: name,
        restaurantId: restaurantId,
      );

      final response = await _menuService.createCategory(input);
      
      if (response.success && response.data != null) {
        _categories.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create category');
        return false;
      }
    } catch (e) {
      _setError('Failed to create category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new menu item
  Future<bool> createItem({
    required String name,
    required String description,
    required String image,
    required double price,
    required int categoryId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final input = CreateMenuItemInput(
        name: name,
        description: description,
        image: image,
        price: price,
        categoryId: categoryId,
      );

      final response = await _menuService.createItem(input);
      
      if (response.success && response.data != null) {
        _items.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create item');
        return false;
      }
    } catch (e) {
      _setError('Failed to create item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing menu item
  Future<bool> updateItem({
    required int itemId,
    String? name,
    String? description,
    String? image,
    double? price,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final input = UpdateMenuItemInput(
        name: name,
        description: description,
        image: image,
        price: price,
      );

      final response = await _menuService.updateItem(itemId, input);
      
      if (response.success && response.data != null) {
        // Update the item in the list
        final index = _items.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _items[index] = response.data!;
        }
        
        // Update current item if it matches
        if (_currentItem?.id == itemId) {
          _currentItem = response.data!;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update item');
        return false;
      }
    } catch (e) {
      _setError('Failed to update item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a menu item
  Future<bool> deleteItem(int itemId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _menuService.deleteItem(itemId);
      
      if (response.success) {
        _items.removeWhere((item) => item.id == itemId);
        
        // Clear current item if it was deleted
        if (_currentItem?.id == itemId) {
          _currentItem = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete item');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a category
  Future<bool> deleteCategory(int categoryId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _menuService.deleteCategory(categoryId);
      
      if (response.success) {
        _categories.removeWhere((category) => category.id == categoryId);
        
        // Clear items if they belong to the deleted category
        _items.removeWhere((item) => item.categoryId == categoryId);
        
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete category');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data
  void clearData() {
    _categories = [];
    _items = [];
    _currentItem = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}