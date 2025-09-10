import '../models/menu/index.dart';
import '../models/api_response.dart';
import 'graphql_service.dart';

class MenuService {
  static final MenuService _instance = MenuService._internal();
  static MenuService get instance => _instance;
  MenuService._internal();

  final GraphQLService _graphql = GraphQLService.instance;

  // GraphQL Queries and Mutations
  static const String _getCategoriesQuery = '''
    query GetCategories(\$restaurantId: Int!) {
      categories(restaurantId: \$restaurantId) {
        id
        name
        restaurantId
        items {
          id
          name
          description
          image
          price
          categoryId
        }
      }
    }
  ''';

  static const String _getItemsQuery = '''
    query GetItems(\$categoryId: Int!) {
      items(categoryId: \$categoryId) {
        id
        name
        description
        image
        price
        categoryId
        category {
          id
          name
          restaurantId
        }
      }
    }
  ''';

  static const String _getItemQuery = '''
    query GetItem(\$id: Int!) {
      item(id: \$id) {
        id
        name
        description
        image
        price
        categoryId
        category {
          id
          name
          restaurantId
        }
      }
    }
  ''';

  static const String _createCategoryMutation = '''
    mutation CreateCategory(\$input: CreateCategoryInput!) {
      createCategory(input: \$input) {
        id
        name
        restaurantId
      }
    }
  ''';

  static const String _createItemMutation = '''
    mutation CreateItem(\$input: CreateItemInput!) {
      createItem(input: \$input) {
        id
        name
        description
        image
        price
        categoryId
        category {
          id
          name
          restaurantId
        }
      }
    }
  ''';

  static const String _updateItemMutation = '''
    mutation UpdateItem(\$id: Int!, \$input: UpdateItemInput!) {
      updateItem(id: \$id, input: \$input) {
        id
        name
        description
        image
        price
        categoryId
        category {
          id
          name
          restaurantId
        }
      }
    }
  ''';

  static const String _deleteItemMutation = '''
    mutation DeleteItem(\$id: Int!) {
      deleteItem(id: \$id)
    }
  ''';

  static const String _deleteCategoryMutation = '''
    mutation DeleteCategory(\$id: Int!) {
      deleteCategory(id: \$id)
    }
  ''';

  // Get all categories for a restaurant
  Future<ApiResponse<List<ItemsCategory>>> getCategories(int restaurantId) async {
    try {
      
      final result = await _graphql.query(
        _getCategoriesQuery,
        variables: {'restaurantId': restaurantId},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['categories'];
      if (data == null) {
        return ApiResponse.error('No categories data received');
      }

      final categories = (data as List<dynamic>)
          .map((categoryJson) => ItemsCategory.fromJson(categoryJson))
          .toList();

      return ApiResponse.success(categories);
    } catch (e) {
      return ApiResponse.error('Failed to fetch categories: $e');
    }
  }

  // Get all items for a category
  Future<ApiResponse<List<MenuItem>>> getItems(int categoryId) async {
    try {
      
      final result = await _graphql.query(
        _getItemsQuery,
        variables: {'categoryId': categoryId},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['items'];
      if (data == null) {
        return ApiResponse.error('No items data received');
      }

      final items = (data as List<dynamic>)
          .map((itemJson) => MenuItem.fromJson(itemJson))
          .toList();

      return ApiResponse.success(items);
    } catch (e) {
      return ApiResponse.error('Failed to fetch items: $e');
    }
  }

  // Get a specific item
  Future<ApiResponse<MenuItem>> getItem(int itemId) async {
    try {
      
      final result = await _graphql.query(
        _getItemQuery,
        variables: {'id': itemId},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['item'];
      if (data == null) {
        return ApiResponse.error('Item not found');
      }

      final item = MenuItem.fromJson(data);
      return ApiResponse.success(item);
    } catch (e) {
      return ApiResponse.error('Failed to fetch item: $e');
    }
  }

  // Create a new category
  Future<ApiResponse<ItemsCategory>> createCategory(CreateCategoryInput input) async {
    try {
      
      final result = await _graphql.mutate(
        _createCategoryMutation,
        variables: {'input': input.toJson()},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['createCategory'];
      if (data == null) {
        return ApiResponse.error('No category data received');
      }

      final category = ItemsCategory.fromJson(data);
      return ApiResponse.success(category);
    } catch (e) {
      return ApiResponse.error('Failed to create category: $e');
    }
  }

  // Create a new menu item
  Future<ApiResponse<MenuItem>> createItem(CreateMenuItemInput input) async {
    try {
      
      final result = await _graphql.mutate(
        _createItemMutation,
        variables: {'input': input.toJson()},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['createItem'];
      if (data == null) {
        return ApiResponse.error('No item data received');
      }

      final item = MenuItem.fromJson(data);
      return ApiResponse.success(item);
    } catch (e) {
      return ApiResponse.error('Failed to create item: $e');
    }
  }

  // Update an existing menu item
  Future<ApiResponse<MenuItem>> updateItem(int itemId, UpdateMenuItemInput input) async {
    try {
      
      final result = await _graphql.mutate(
        _updateItemMutation,
        variables: {
          'id': itemId,
          'input': input.toJson(),
        },
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['updateItem'];
      if (data == null) {
        return ApiResponse.error('No updated item data received');
      }

      final item = MenuItem.fromJson(data);
      return ApiResponse.success(item);
    } catch (e) {
      return ApiResponse.error('Failed to update item: $e');
    }
  }

  // Delete a menu item
  Future<ApiResponse<bool>> deleteItem(int itemId) async {
    try {
      
      final result = await _graphql.mutate(
        _deleteItemMutation,
        variables: {'id': itemId},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['deleteItem'];
      if (data == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Failed to delete item');
      }
    } catch (e) {
      return ApiResponse.error('Failed to delete item: $e');
    }
  }

  // Delete a category
  Future<ApiResponse<bool>> deleteCategory(int categoryId) async {
    try {
      
      final result = await _graphql.mutate(
        _deleteCategoryMutation,
        variables: {'id': categoryId},
      );

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['deleteCategory'];
      if (data == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Failed to delete category');
      }
    } catch (e) {
      return ApiResponse.error('Failed to delete category: $e');
    }
  }
}
