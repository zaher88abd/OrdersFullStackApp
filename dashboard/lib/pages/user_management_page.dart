import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import '../widgets/user_management/user_account_table.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Account Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(child: UserAccountTable()),
        ],
      ),
    );
  }
}