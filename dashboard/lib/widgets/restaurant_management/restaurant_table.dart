import 'package:flutter/material.dart';
import '../../services/restaurant_service.dart';
import '../../models/api_response.dart';
import '../../models/restaurant.dart';
import 'restaurant_action_buttons.dart';

class RestaurantTable extends StatefulWidget {
  const RestaurantTable({super.key});

  @override
  State<RestaurantTable> createState() => _RestaurantTableState();
}

class _RestaurantTableState extends State<RestaurantTable> {
  final RestaurantService _restaurantService = RestaurantService.instance;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _restaurantService.getAllRestaurants();
    
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _restaurants = response.data ?? [];
      } else {
        _error = response.error;
      }
    });
  }

  Future<void> _showCreateRestaurantDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateRestaurantDialog(),
    );
    
    if (result == true) {
      _loadRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Restaurants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateRestaurantDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Restaurant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _loadRestaurants,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
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
              onPressed: _loadRestaurants,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No restaurants found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click "Add Restaurant" to create your first restaurant',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateRestaurantDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Restaurant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
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
              DataColumn(label: Text('Restaurant Name')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Created Date')),
              DataColumn(label: Text('Team Members')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _restaurants.map((restaurant) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(restaurant.address)),
                  DataCell(Text(restaurant.phone)),
                  DataCell(
                    Text(
                      restaurant.createdAt != null
                          ? '${restaurant.createdAt!.day}/${restaurant.createdAt!.month}/${restaurant.createdAt!.year}'
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    Chip(
                      label: Text('${restaurant.restaurantTeam.length}'),
                      backgroundColor: Colors.blue[100],
                      labelStyle: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                  DataCell(
                    RestaurantActionButtons(
                      restaurant: restaurant,
                      onRestaurantUpdated: _loadRestaurants,
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

class _CreateRestaurantDialog extends StatefulWidget {
  @override
  State<_CreateRestaurantDialog> createState() => _CreateRestaurantDialogState();
}

class _CreateRestaurantDialogState extends State<_CreateRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final restaurantService = RestaurantService.instance;
    
    try {
      final response = await restaurantService.createRestaurant(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        adminName: _adminNameController.text.trim(),
        adminEmail: _adminEmailController.text.trim(),
      );

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant created successfully! Invitation sent to admin.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.error ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create restaurant: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Restaurant'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  hintText: 'Enter restaurant name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Restaurant name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter restaurant address',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Admin User Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminNameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name',
                  hintText: 'Enter admin name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Admin name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminEmailController,
                decoration: const InputDecoration(
                  labelText: 'Admin Email',
                  hintText: 'Enter admin email address',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Admin email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createRestaurant,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Restaurant'),
        ),
      ],
    );
  }
}