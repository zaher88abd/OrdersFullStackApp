import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/api_response.dart';
import '../models/user.dart';
import 'graphql_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  final GraphQLService _graphql = GraphQLService.instance;
  
  // GraphQL Mutations
  static const String _createRestaurantMutation = '''
    mutation CreateRestaurant(\$input: CreateRestaurantInput!) {
      createRestaurant(input: \$input) {
        success
        message
        restaurant {
          id
          name
          address
          phone
          restaurantCode
          createdAt
          updatedAt
        }
        restaurantCode
        accountCreated
        emailSent
      }
    }
  ''';

  static const String _joinRestaurantMutation = '''
    mutation JoinRestaurant(\$input: JoinRestaurantInput!) {
      joinRestaurant(input: \$input) {
        success
        message
        restaurantName
        accountCreated
        emailSent
      }
    }
  ''';

  static const String _verifyEmailMutation = '''
    mutation VerifyEmail(\$input: VerifyEmailInput!) {
      verifyEmail(input: \$input) {
        success
        message
        restaurantCode
      }
    }
  ''';

  static const String _signInMutation = '''
    mutation SignIn(\$input: SignInInput!) {
      signIn(input: \$input) {
        success
        message
        user {
          id
          email
          role
        }
        accessToken
        refreshToken
      }
    }
  ''';

  // ðŸ”„ New: Get current user profile
  static const String _getUserProfileQuery = '''
    query GetUserProfile {
      userProfile {
        id
        email
        role
        teamMember {
          uuid
          name
          email
          jobType
          restaurantId
          isActive
          emailVerified
          createdAt
          updatedAt
        }
        restaurant {
          id
          name
          address
          phone
          restaurantCode
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // Create Restaurant (Manager Registration)
  Future<RestaurantCreationResult> createRestaurant({
    required String restaurantName,
    required String address,
    required String phone,
    required String managerName,
    required String managerEmail,
    required String managerPassword,
  }) async {
    try {
      
      final result = await _graphql.mutate(
        _createRestaurantMutation,
        variables: {
          'input': {
            'name': restaurantName,
            'address': address,
            'phone': phone,
            'managerName': managerName,
            'managerEmail': managerEmail,
            'managerPassword': managerPassword,
          }
        },
      );


      if (result.hasException) {
        return RestaurantCreationResult(
          success: false,
          message: result.exception.toString(),
          accountCreated: false,
          emailSent: false,
        );
      }

      final data = result.data?['createRestaurant'];
      
      if (data == null) {
        return RestaurantCreationResult(
          success: false,
          message: 'No data received from server',
          accountCreated: false,
          emailSent: false,
        );
      }

      final creationResult = RestaurantCreationResult.fromJson(data);
      
      return creationResult;
    } catch (e) {
      return RestaurantCreationResult(
        success: false,
        message: 'Failed to create restaurant: $e',
        accountCreated: false,
        emailSent: false,
      );
    }
  }

  // Join Restaurant (Staff Registration)
  Future<JoinRestaurantResult> joinRestaurant({
    required String restaurantCode,
    required String name,
    required String email,
    required String password,
    required JobType jobType,
  }) async {
    try {
      final result = await _graphql.mutate(
        _joinRestaurantMutation,
        variables: {
          'input': {
            'restaurantCode': restaurantCode,
            'name': name,
            'email': email,
            'password': password,
            'jobType': jobType.value,
          }
        },
      );

      if (result.hasException) {
        return JoinRestaurantResult(
          success: false,
          message: result.exception.toString(),
          accountCreated: false,
          emailSent: false,
        );
      }

      final data = result.data?['joinRestaurant'];
      if (data == null) {
        return JoinRestaurantResult(
          success: false,
          message: 'No data received from server',
          accountCreated: false,
          emailSent: false,
        );
      }

      return JoinRestaurantResult.fromJson(data);
    } catch (e) {
      return JoinRestaurantResult(
        success: false,
        message: 'Failed to join restaurant: $e',
        accountCreated: false,
        emailSent: false,
      );
    }
  }

  // Email Verification
  Future<VerifyEmailResult> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final result = await _graphql.mutate(
        _verifyEmailMutation,
        variables: {
          'input': {
            'email': email,
            'verificationCode': verificationCode,
          }
        },
      );

      if (result.hasException) {
        return VerifyEmailResult(
          success: false,
          message: result.exception.toString(),
        );
      }

      final data = result.data?['verifyEmail'];
      if (data == null) {
        return VerifyEmailResult(
          success: false,
          message: 'No data received from server',
        );
      }

      return VerifyEmailResult.fromJson(data);
    } catch (e) {
      return VerifyEmailResult(
        success: false,
        message: 'Failed to verify email: $e',
      );
    }
  }

  // Sign In
  Future<ApiResponse<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      
      final result = await _graphql.mutate(
        _signInMutation,
        variables: {
          'input': {
            'email': email,
            'password': password,
          }
        },
      );


      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['signIn'];
      
      if (data == null) {
        return ApiResponse.error('No data received from server');
      }

      if (!data['success']) {
        return ApiResponse.error(data['message'] ?? 'Sign in failed');
      }

      // Store the access token first
      if (data['accessToken'] != null) {
        await saveAuthToken(data['accessToken']);
      }

      // Get the complete user profile with restaurant data
      final userProfileResponse = await getCurrentUser();

      if (userProfileResponse.success && userProfileResponse.data != null) {
        // ðŸ"„ Save user data locally for persistence
        await saveUserData(userProfileResponse.data!);

        return ApiResponse.success(
          userProfileResponse.data!,
          message: data['message'] ?? 'Sign in successful',
        );
      } else {
        return ApiResponse.error('Failed to fetch user profile: ${userProfileResponse.message}');
      }
    } catch (e) {
      return ApiResponse.error('Failed to sign in: $e');
    }
  }

  // ðŸ”„ New: Get current user from server (for token validation)
  Future<ApiResponse<AuthUser>> getCurrentUser() async {
    try {
      final result = await _graphql.query(_getUserProfileQuery);

      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final data = result.data?['userProfile'];
      if (data == null) {
        return ApiResponse.error('No user profile data received');
      }

      // Check if user is linked to a restaurant team
      if (data['teamMember'] == null || data['restaurant'] == null) {
        return ApiResponse.error('User is not associated with any restaurant. Please contact your restaurant admin to add you to the team.');
      }

      // Parse the user profile data
      final authUser = AuthUser(
        user: User.fromJson(data['teamMember']),
        restaurant: Restaurant.fromJson(data['restaurant']),
        accessToken: await getAuthToken(),
      );

      // Update locally stored user data
      await saveUserData(authUser);

      return ApiResponse.success(authUser);
    } catch (e) {
      return ApiResponse.error('Failed to get current user: $e');
    }
  }

  // ðŸ”„ Enhanced: Storage Methods with User Data
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _graphql.updateAuthToken(token);
  }

  Future<void> saveUserData(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    if (user.accessToken != null) {
      await saveAuthToken(user.accessToken!);
    }
  }

  Future<AuthUser?> getSavedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return AuthUser.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      // If there's an error parsing saved data, clear it
      await clearUserData();
    }
    return null;
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _graphql.clearAuthToken();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await clearAuthToken();
  }

  // ðŸ”„ Enhanced: Check login status with token validation
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Optional: Validate token with server
    try {
      final userResponse = await getCurrentUser();
      return userResponse.success;
    } catch (e) {
      // If token validation fails, clear invalid token
      await clearUserData();
      return false;
    }
  }

  // ðŸ”„ Enhanced: Auto-restore user session
  Future<AuthUser?> restoreSession() async {
    try {
      final savedUser = await getSavedUserData();
      if (savedUser != null) {
        // Validate session with server
        final userResponse = await getCurrentUser();
        if (userResponse.success && userResponse.data != null) {
          return userResponse.data;
        }
      }
    } catch (e) {
      // Session restore failed, clear invalid data
      await clearUserData();
    }
    return null;
  }
}
