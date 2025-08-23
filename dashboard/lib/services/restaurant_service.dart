import '../models/api_response.dart';
import '../models/restaurant.dart';
import 'graphql_service.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  static RestaurantService get instance => _instance;
  RestaurantService._internal();

  final GraphQLService _graphQL = GraphQLService.instance;

  // Queries
  static const String _getAllRestaurantsQuery = '''
    query GetAllRestaurants {
      restaurants {
        id
        name
        address
        phone
        restaurantCode
        createdAt
        updatedAt
        restaurantTeam {
          uuid
          name
          email
          jobType
          isActive
          emailVerified
          createdAt
          updatedAt
        }
      }
    }
  ''';

  static const String _getRestaurantByIdQuery = '''
    query GetRestaurant(\$id: Int!) {
      restaurant(id: \$id) {
        id
        name
        address
        phone
        restaurantCode
        createdAt
        updatedAt
        restaurantTeam {
          uuid
          name
          email
          jobType
          isActive
          emailVerified
          createdAt
          updatedAt
        }
        categories {
          id
          name
        }
        rtables {
          id
          name
        }
      }
    }
  ''';

  // Mutations
  static const String _createRestaurantMutation = '''
    mutation CreateRestaurant(\$input: CreateRestaurantInput!) {
      createRestaurant(input: \$input) {
        success
        message
        invitationSent
        restaurant {
          id
          name
          address
          phone
          createdAt
          updatedAt
        }
      }
    }
  ''';

  static const String _updateRestaurantMutation = '''
    mutation UpdateRestaurant(\$id: Int!, \$input: UpdateRestaurantInput!) {
      updateRestaurant(id: \$id, input: \$input) {
        id
        name
        address
        phone
        createdAt
        updatedAt
      }
    }
  ''';

  static const String _deleteRestaurantMutation = '''
    mutation DeleteRestaurant(\$id: Int!) {
      deleteRestaurant(id: \$id)
    }
  ''';

  // Service Methods

  Future<ApiResponse<List<Restaurant>>> getAllRestaurants() async {
    try {
      final result = await _graphQL.query(_getAllRestaurantsQuery);
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final restaurantsData = result.data?['restaurants'] as List?;
      if (restaurantsData == null) {
        return ApiResponse.error('No restaurants data received');
      }

      final restaurants = restaurantsData
          .map((json) => Restaurant.fromJson(json))
          .toList();

      return ApiResponse.success(restaurants);
    } catch (e) {
      return ApiResponse.error('Failed to fetch restaurants: $e');
    }
  }

  // Simplified method for direct use
  Future<List<Restaurant>> getRestaurants() async {
    final response = await getAllRestaurants();
    if (response.success) {
      return response.data!;
    } else {
      throw Exception(response.error);
    }
  }

  Future<ApiResponse<Restaurant>> getRestaurantById(int id) async {
    try {
      final result = await _graphQL.query(
        _getRestaurantByIdQuery,
        variables: {'id': id},
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final restaurantData = result.data?['restaurant'];
      if (restaurantData == null) {
        return ApiResponse.error('Restaurant not found');
      }

      final restaurant = Restaurant.fromJson(restaurantData);
      return ApiResponse.success(restaurant);
    } catch (e) {
      return ApiResponse.error('Failed to fetch restaurant: $e');
    }
  }

  Future<ApiResponse<RestaurantCreationResult>> createRestaurant({
    required String name,
    required String address,
    required String phone,
    required String adminName,
    required String adminEmail,
  }) async {
    try {
      final result = await _graphQL.mutate(
        _createRestaurantMutation,
        variables: {
          'input': {
            'name': name,
            'address': address,
            'phone': phone,
            'adminName': adminName,
            'adminEmail': adminEmail,
          },
        },
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final createRestaurantData = result.data?['createRestaurant'];
      if (createRestaurantData == null) {
        return ApiResponse.error('No response data received');
      }

      final creationResult = RestaurantCreationResult.fromJson(createRestaurantData);
      return ApiResponse.success(creationResult);
    } catch (e) {
      return ApiResponse.error('Failed to create restaurant: $e');
    }
  }

  Future<ApiResponse<Restaurant>> updateRestaurant({
    required int id,
    String? name,
    String? address,
    String? phone,
  }) async {
    try {
      final input = <String, dynamic>{};
      if (name != null) input['name'] = name;
      if (address != null) input['address'] = address;
      if (phone != null) input['phone'] = phone;

      final result = await _graphQL.mutate(
        _updateRestaurantMutation,
        variables: {
          'id': id,
          'input': input,
        },
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final restaurantData = result.data?['updateRestaurant'];
      if (restaurantData == null) {
        return ApiResponse.error('Failed to update restaurant');
      }

      final restaurant = Restaurant.fromJson(restaurantData);
      return ApiResponse.success(restaurant);
    } catch (e) {
      return ApiResponse.error('Failed to update restaurant: $e');
    }
  }

  Future<ApiResponse<bool>> deleteRestaurant(int id) async {
    try {
      final result = await _graphQL.mutate(
        _deleteRestaurantMutation,
        variables: {'id': id},
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final success = result.data?['deleteRestaurant'] as bool? ?? false;
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error('Failed to delete restaurant: $e');
    }
  }
}