import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';
import '../../models/restaurant.dart';
import 'user_action_buttons.dart';
import 'pending_invitation_actions.dart';

class UserAccountTable extends StatefulWidget {
  const UserAccountTable({super.key});

  @override
  State<UserAccountTable> createState() => _UserAccountTableState();
}

class _UserAccountTableState extends State<UserAccountTable> {
  final UserService _userService = UserService.instance;
  UserData? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _userService.getAllUsers();
    
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _userData = response.data;
      } else {
        _error = response.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final userData = _userData!;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Header with refresh button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          // Tab bar
          TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    Text('Active Users (${userData.totalActiveUsers})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pending),
                    const SizedBox(width: 8),
                    Text('Pending Invitations (${userData.totalPendingInvitations})'),
                  ],
                ),
              ),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                // Active Users Tab
                _buildActiveUsersTab(userData.activeUsers),
                // Pending Invitations Tab
                _buildPendingInvitationsTab(userData.pendingInvitations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersTab(List<RestaurantTeamMember> activeUsers) {
    if (activeUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Users will appear here after completing their invitations',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Job Type')),
              DataColumn(label: Text('Restaurant')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Joined Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: activeUsers.map((user) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(user.jobType.name)),
                  DataCell(Text(user.restaurantName ?? 'N/A')),
                  DataCell(
                    Chip(
                      label: Text(user.isActive ? 'Active' : 'Inactive'),
                      backgroundColor: user.isActive
                          ? Colors.green[100]
                          : Colors.orange[100],
                      labelStyle: TextStyle(
                        color: user.isActive
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      user.createdAt != null
                          ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    UserActionButtons(
                      user: user,
                      onUserUpdated: _loadUsers,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingInvitationsTab(List<RestaurantTeamMember> pendingInvitations) {
    if (pendingInvitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pending invitations',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create restaurants to send invitations to admins',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Admin Name')),
              DataColumn(label: Text('Restaurant')),
              DataColumn(label: Text('Job Type')),
              DataColumn(label: Text('Invitation Sent')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: pendingInvitations.map((invitation) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        const Icon(Icons.mail, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          invitation.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(invitation.restaurantName ?? 'N/A')),
                  DataCell(Text(invitation.jobType.name)),
                  DataCell(
                    Text(
                      invitation.createdAt != null
                          ? '${invitation.createdAt!.day}/${invitation.createdAt!.month}/${invitation.createdAt!.year}'
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    Chip(
                      label: const Text('Pending'),
                      backgroundColor: Colors.orange[100],
                      labelStyle: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                  DataCell(
                    PendingInvitationActions(
                      invitation: invitation,
                      onInvitationUpdated: _loadUsers,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}