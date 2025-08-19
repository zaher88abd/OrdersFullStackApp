import '../models/api_response.dart';
import 'graphql_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  final GraphQLService _graphQL = GraphQLService.instance;

  // Queries
  static const String _meQuery = '''
    query Me {
      me {
        id
        email
        role
      }
    }
  ''';

  static const String _userProfileQuery = '''
    query UserProfile {
      userProfile {
        id
        email
        role
        teamMember {
          uuid
          name
          jobType
          isActive
          restaurant {
            id
            name
            address
            phone
          }
        }
      }
    }
  ''';

  // Mutations
  static const String _signUpMutation = '''
    mutation SignUp(\$input: SignUpInput!) {
      signUp(input: \$input) {
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

  static const String _signOutMutation = '''
    mutation SignOut {
      signOut {
        success
        message
      }
    }
  ''';

  static const String _completeInvitationMutation = '''
    mutation CompleteInvitation(\$tempUuid: String!) {
      completeInvitation(tempUuid: \$tempUuid) {
        success
        message
        user {
          id
          email
          role
        }
      }
    }
  ''';

  // Service Methods

  Future<ApiResponse<AuthUser>> getCurrentUser() async {
    try {
      final result = await _graphQL.query(_meQuery);
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final userData = result.data?['me'];
      if (userData == null) {
        return ApiResponse.error('User not authenticated');
      }

      final user = AuthUser.fromJson(userData);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to get current user: $e');
    }
  }

  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      final result = await _graphQL.query(_userProfileQuery);
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final profileData = result.data?['userProfile'];
      if (profileData == null) {
        return ApiResponse.error('User profile not found');
      }

      final profile = UserProfile.fromJson(profileData);
      return ApiResponse.success(profile);
    } catch (e) {
      return ApiResponse.error('Failed to get user profile: $e');
    }
  }

  Future<ApiResponse<AuthResult>> signUp({
    required String email,
    required String password,
    String? name,
    String? role,
  }) async {
    try {
      final result = await _graphQL.mutate(
        _signUpMutation,
        variables: {
          'input': {
            'email': email,
            'password': password,
            'name': name,
            'role': role ?? 'user',
          },
        },
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final authData = result.data?['signUp'];
      if (authData == null) {
        return ApiResponse.error('No response data received');
      }

      final authResult = AuthResult.fromJson(authData);
      return ApiResponse.success(authResult);
    } catch (e) {
      return ApiResponse.error('Failed to sign up: $e');
    }
  }

  Future<ApiResponse<AuthResult>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _graphQL.mutate(
        _signInMutation,
        variables: {
          'input': {
            'email': email,
            'password': password,
          },
        },
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final authData = result.data?['signIn'];
      if (authData == null) {
        return ApiResponse.error('No response data received');
      }

      final authResult = AuthResult.fromJson(authData);
      return ApiResponse.success(authResult);
    } catch (e) {
      return ApiResponse.error('Failed to sign in: $e');
    }
  }

  Future<ApiResponse<bool>> signOut() async {
    try {
      final result = await _graphQL.mutate(_signOutMutation);
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final signOutData = result.data?['signOut'];
      final success = signOutData?['success'] as bool? ?? false;
      
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error('Failed to sign out: $e');
    }
  }

  Future<ApiResponse<AuthResult>> completeInvitation(String tempUuid) async {
    try {
      final result = await _graphQL.mutate(
        _completeInvitationMutation,
        variables: {'tempUuid': tempUuid},
      );
      
      if (result.hasException) {
        return ApiResponse.error(result.exception.toString());
      }

      final authData = result.data?['completeInvitation'];
      if (authData == null) {
        return ApiResponse.error('No response data received');
      }

      final authResult = AuthResult.fromJson(authData);
      return ApiResponse.success(authResult);
    } catch (e) {
      return ApiResponse.error('Failed to complete invitation: $e');
    }
  }
}

// Auth Models
class AuthUser {
  final String id;
  final String email;
  final String role;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String role;
  final Map<String, dynamic>? teamMember;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.teamMember,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      teamMember: json['teamMember'],
    );
  }
}

class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'],
      message: json['message'],
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}