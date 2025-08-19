import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/restaurant.dart';

class UserActionButtons extends StatelessWidget {
  final RestaurantTeamMember user;
  final VoidCallback? onUserUpdated;

  const UserActionButtons({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle Active/Inactive
        IconButton(
          onPressed: () => _toggleUserStatus(context),
          icon: Icon(
            user.isActive ? Icons.block : Icons.check_circle,
            color: user.isActive ? Colors.orange : Colors.green,
          ),
          tooltip: user.isActive ? 'Disable Account' : 'Activate Account',
        ),
        // Delete User
        IconButton(
          onPressed: () => _deleteUser(context),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete Account',
        ),
      ],
    );
  }

  Future<void> _toggleUserStatus(BuildContext context) async {
    final userService = UserService.instance;
    
    try {
      final response = await userService.updateUser(
        uuid: user.uuid,
        isActive: !user.isActive,
      );

      if (response.isSuccess) {
        onUserUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'User account disabled successfully'
                  : 'User account activated successfully',
            ),
          ),
        );
      } else {
        _showErrorSnackBar(context, response.error ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to update user: $e');
    }
  }

  Future<void> _deleteUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User Account'),
        content: Text(
          'Are you sure you want to delete ${user.name}\'s account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userService = UserService.instance;
    
    try {
      final response = await userService.deleteUser(user.uuid);

      if (response.isSuccess) {
        onUserUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User account deleted successfully'),
          ),
        );
      } else {
        _showErrorSnackBar(context, response.error ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to delete user: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }
}