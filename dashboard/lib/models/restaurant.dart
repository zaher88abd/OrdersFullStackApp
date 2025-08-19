enum JobType { MANAGER, CHEF, WAITER }

class Restaurant {
  final int id;
  final String name;
  final String address;
  final String phone;
  final List<RestaurantTeamMember> restaurantTeam;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.restaurantTeam,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final teamList = json['restaurantTeam'] as List? ?? [];
    final team = teamList
        .map((teamJson) => RestaurantTeamMember.fromJson({
              ...teamJson,
              'restaurantName': json['name'],
              'restaurantId': json['id'],
            }))
        .toList();

    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      restaurantTeam: team,
    );
  }

  int get totalStaff => restaurantTeam.length;
  int get activeStaff => restaurantTeam.where((member) => member.isActive).length;
}

class RestaurantTeamMember {
  final String uuid;
  final String name;
  final JobType jobType;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? restaurantName;
  final int? restaurantId;

  RestaurantTeamMember({
    required this.uuid,
    required this.name,
    required this.jobType,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.restaurantName,
    this.restaurantId,
  });

  factory RestaurantTeamMember.fromJson(Map<String, dynamic> json) {
    return RestaurantTeamMember(
      uuid: json['uuid'],
      name: json['name'],
      jobType: _jobTypeFromString(json['jobType']),
      isActive: json['isActive'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      restaurantName: json['restaurantName'],
      restaurantId: json['restaurantId'],
    );
  }

  bool get isPendingInvitation => !isActive && uuid.startsWith('temp_');

  static JobType _jobTypeFromString(String jobType) {
    switch (jobType.toUpperCase()) {
      case 'MANAGER':
        return JobType.MANAGER;
      case 'CHEF':
        return JobType.CHEF;
      case 'WAITER':
        return JobType.WAITER;
      default:
        return JobType.WAITER;
    }
  }
}

class RestaurantCreationResult {
  final bool success;
  final String message;
  final Restaurant? restaurant;
  final bool invitationSent;

  RestaurantCreationResult({
    required this.success,
    required this.message,
    this.restaurant,
    required this.invitationSent,
  });

  factory RestaurantCreationResult.fromJson(Map<String, dynamic> json) {
    return RestaurantCreationResult(
      success: json['success'],
      message: json['message'],
      restaurant: json['restaurant'] != null 
          ? Restaurant.fromJson(json['restaurant']) 
          : null,
      invitationSent: json['invitationSent'],
    );
  }
}