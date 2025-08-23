import 'restaurant.dart';

class User {
  final String uuid;
  final String name;
  final String? email;
  final String jobType;
  final int restaurantId;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Restaurant? restaurant;

  User({
    required this.uuid,
    required this.name,
    this.email,
    required this.jobType,
    required this.restaurantId,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.restaurant,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      jobType: json['jobType'],
      restaurantId: json['restaurantId'],
      isActive: json['isActive'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      restaurant: json['restaurant'] != null 
          ? Restaurant.fromJson(json['restaurant']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
      'jobType': jobType,
      'restaurantId': restaurantId,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'restaurant': restaurant?.toJson(),
    };
  }
}

class UserData {
  final List<RestaurantTeamMember> activeUsers;
  final List<RestaurantTeamMember> pendingInvitations;

  UserData({
    required this.activeUsers,
    required this.pendingInvitations,
  });

  int get totalActiveUsers => activeUsers.length;
  int get totalPendingInvitations => pendingInvitations.length;
  int get totalUsers => totalActiveUsers + totalPendingInvitations;
}