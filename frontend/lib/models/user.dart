import '../utils/datetime_utils.dart';

class User {
  final String uuid;
  final String name;
  final String email;
  final String jobType;
  final int restaurantId;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uuid,
    required this.name,
    required this.email,
    required this.jobType,
    required this.restaurantId,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: DateTimeUtils.parseDateTime(json['createdAt']),
      updatedAt: DateTimeUtils.parseDateTime(json['updatedAt']),
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
      'createdAt': DateTimeUtils.dateTimeToJson(createdAt),
      'updatedAt': DateTimeUtils.dateTimeToJson(updatedAt),
    };
  }

  bool get isManager => jobType.toUpperCase() == 'MANAGER';
  bool get isChef => jobType.toUpperCase() == 'CHEF';
  bool get isWaiter => jobType.toUpperCase() == 'WAITER';
}

class Restaurant {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? restaurantCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.restaurantCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      restaurantCode: json['restaurantCode'],
      createdAt: DateTimeUtils.parseDateTime(json['createdAt']),
      updatedAt: DateTimeUtils.parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'restaurantCode': restaurantCode,
      'createdAt': DateTimeUtils.dateTimeToJson(createdAt),
      'updatedAt': DateTimeUtils.dateTimeToJson(updatedAt),
    };
  }
}

enum JobType {
  manager('MANAGER'),
  chef('CHEF'),
  waiter('WAITER');

  const JobType(this.value);
  final String value;

  static JobType fromString(String value) {
    return JobType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => JobType.waiter,
    );
  }
}

class AuthUser {
  final User user;
  final Restaurant restaurant;
  final String? accessToken;

  AuthUser({required this.user, required this.restaurant, this.accessToken});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    print("user info ${json}");
    return AuthUser(
      user: User.fromJson(json['user']),
      restaurant: Restaurant.fromJson(json['restaurant']),
      accessToken: json['accessToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'restaurant': restaurant.toJson(),
      'accessToken': accessToken,
    };
  }
}
