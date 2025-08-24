import 'user.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(
      success: false,
      message: error,
      error: error,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['success'] && json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['success'] ? null : (json['error'] ?? json['message']),
    );
  }
}

class RestaurantCreationResult {
  final bool success;
  final String message;
  final Restaurant? restaurant;
  final String? restaurantCode;
  final bool accountCreated;
  final bool emailSent;

  RestaurantCreationResult({
    required this.success,
    required this.message,
    this.restaurant,
    this.restaurantCode,
    required this.accountCreated,
    required this.emailSent,
  });

  factory RestaurantCreationResult.fromJson(Map<String, dynamic> json) {
    return RestaurantCreationResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      restaurant: json['restaurant'] != null 
          ? Restaurant.fromJson(json['restaurant']) 
          : null,
      restaurantCode: json['restaurantCode'],
      accountCreated: json['accountCreated'] ?? false,
      emailSent: json['emailSent'] ?? false,
    );
  }
}

class JoinRestaurantResult {
  final bool success;
  final String message;
  final String? restaurantName;
  final bool accountCreated;
  final bool emailSent;

  JoinRestaurantResult({
    required this.success,
    required this.message,
    this.restaurantName,
    required this.accountCreated,
    required this.emailSent,
  });

  factory JoinRestaurantResult.fromJson(Map<String, dynamic> json) {
    return JoinRestaurantResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      restaurantName: json['restaurantName'],
      accountCreated: json['accountCreated'] ?? false,
      emailSent: json['emailSent'] ?? false,
    );
  }
}

class VerifyEmailResult {
  final bool success;
  final String message;
  final String? restaurantCode;

  VerifyEmailResult({
    required this.success,
    required this.message,
    this.restaurantCode,
  });

  factory VerifyEmailResult.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      restaurantCode: json['restaurantCode'],
    );
  }
}