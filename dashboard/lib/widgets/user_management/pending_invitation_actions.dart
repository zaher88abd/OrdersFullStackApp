import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/restaurant.dart';

class PendingInvitationActions extends StatelessWidget {
  final RestaurantTeamMember invitation;
  final VoidCallback? onInvitationUpdated;

  const PendingInvitationActions({
    super.key,
    required this.invitation,
    this.onInvitationUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Resend Invitation
        IconButton(
          onPressed: () => _resendInvitation(context),
          icon: const Icon(Icons.send, color: Colors.blue),
          tooltip: 'Resend Invitation',
        ),
        // Cancel Invitation
        IconButton(
          onPressed: () => _cancelInvitation(context),
          icon: const Icon(Icons.cancel, color: Colors.red),
          tooltip: 'Cancel Invitation',
        ),
      ],
    );
  }

  Future<void> _resendInvitation(BuildContext context) async {
    final userService = UserService.instance;
    
    try {
      // For now, we'll just show a message since resend functionality
      // would require additional backend implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resend invitation functionality coming soon'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to resend invitation: $e');
    }
  }

  Future<void> _cancelInvitation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Invitation'),
        content: Text(
          'Are you sure you want to cancel the invitation for ${invitation.name}? '
          'They will no longer be able to join the restaurant.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Invitation'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Invitation'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userService = UserService.instance;
    
    try {
      final response = await userService.deleteUser(invitation.uuid);

      if (response.isSuccess) {
        onInvitationUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation cancelled successfully'),
          ),
        );
      } else {
        _showErrorSnackBar(context, response.error ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to cancel invitation: $e');
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