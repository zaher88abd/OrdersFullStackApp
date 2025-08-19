import 'restaurant.dart';

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