import '../models/api_response.dart';
import '../models/user.dart';
import 'graphql_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  UserService._internal();

  final GraphQLService _graphQL = GraphQLService.instance;

  // Queries
  static const String _getAllUsersQuery = '''
    query GetAllUsers {
      restaurants {
        id
        name
        restaurantTeam {
          uuid
          name
          jobType
          isActive
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // Mutations
  static const String _updateUserMutation = '''
    mutation UpdateUser(\$uuid: String!, \$input: UpdateRestaurantTeamInput!) {
      updateRestaurantTeam(uuid: \$uuid, input: \$input) {
        uuid
        name
        jobType
        isActive
        updatedAt
      }
    }
  ''';

  static const String _deleteUserMutation = '''
    mutation DeleteUser(\$uuid: String!) {
      deleteRestaurantTeam(uuid: \$uuid)
    }
  ''';

  // Service Methods

  Future<ApiResponse<UserData>> getAllUsers() async {
    try {
      final result = await _graphQL.query(_getAllUsersQuery);
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final restaurantsData = result.data?['restaurants'] as List?;
      if (restaurantsData == null) {
        return ApiResponse.error('No restaurants data received');
      }

      // Flatten all restaurant team members and categorize them
      final activeUsers = <RestaurantTeamMember>[];
      final pendingInvitations = <RestaurantTeamMember>[];

      for (final restaurant in restaurantsData) {
        final restaurantTeam = restaurant['restaurantTeam'] as List?;
        if (restaurantTeam != null) {
          for (final userJson in restaurantTeam) {
            final user = RestaurantTeamMember.fromJson({
              ...userJson,
              'restaurantName': restaurant['name'],
              'restaurantId': restaurant['id'],
            });
            
            // Check if this is a pending invitation (temp UUID and inactive)
            if (!user.isActive && user.uuid.startsWith('temp_')) {
              pendingInvitations.add(user);
            } else {
              activeUsers.add(user);
            }
          }
        }
      }

      final userData = UserData(
        activeUsers: activeUsers,
        pendingInvitations: pendingInvitations,
      );

      return ApiResponse.success(userData);
    } catch (e) {
      return ApiResponse.error('Failed to fetch users: $e');
    }
  }

  Future<ApiResponse<RestaurantTeamMember>> updateUser({
    required String uuid,
    String? name,
    String? jobType,
    bool? isActive,
  }) async {
    try {
      final input = <String, dynamic>{};
      if (name != null) input['name'] = name;
      if (jobType != null) input['jobType'] = jobType;
      if (isActive != null) input['isActive'] = isActive;

      final result = await _graphQL.mutate(
        _updateUserMutation,
        variables: {
          'uuid': uuid,
          'input': input,
        },
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final userData = result.data?['updateRestaurantTeam'];
      if (userData == null) {
        return ApiResponse.error('Failed to update user');
      }

      final user = RestaurantTeamMember.fromJson(userData);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to update user: $e');
    }
  }

  Future<ApiResponse<bool>> deleteUser(String uuid) async {
    try {
      final result = await _graphQL.mutate(
        _deleteUserMutation,
        variables: {'uuid': uuid},
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final success = result.data?['deleteRestaurantTeam'] as bool? ?? false;
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error('Failed to delete user: $e');
    }
  }

  Future<ApiResponse<bool>> cancelInvitation(String uuid) async {
    // Same as delete user for now
    return deleteUser(uuid);
  }

  Future<ApiResponse<bool>> resendInvitation(String uuid) async {
    // TODO: Implement resend invitation logic
    try {
      // For now, return a placeholder response
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse.error('Resend invitation feature not implemented yet');
    } catch (e) {
      return ApiResponse.error('Failed to resend invitation: $e');
    }
  }
}