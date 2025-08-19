import 'package:flutter/material.dart';
import '../widgets/restaurant_management/restaurant_table.dart';

class RestaurantManagementPage extends StatelessWidget {
  const RestaurantManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(child: RestaurantTable()),
        ],
      ),
    );
  }
}