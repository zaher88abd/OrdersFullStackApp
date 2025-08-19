import 'package:flutter/material.dart';
import '../../services/restaurant_service.dart';
import '../../models/restaurant.dart';

class RestaurantActionButtons extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback? onRestaurantUpdated;

  const RestaurantActionButtons({
    super.key,
    required this.restaurant,
    this.onRestaurantUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Details
        IconButton(
          onPressed: () => _viewRestaurantDetails(context),
          icon: const Icon(Icons.info, color: Colors.blue),
          tooltip: 'View Details',
        ),
        // Edit Restaurant
        IconButton(
          onPressed: () => _editRestaurant(context),
          icon: const Icon(Icons.edit, color: Colors.orange),
          tooltip: 'Edit Restaurant',
        ),
        // Delete Restaurant
        IconButton(
          onPressed: () => _deleteRestaurant(context),
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Delete Restaurant',
        ),
      ],
    );
  }

  Future<void> _viewRestaurantDetails(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => _RestaurantDetailsDialog(restaurant: restaurant),
    );
  }

  Future<void> _editRestaurant(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditRestaurantDialog(restaurant: restaurant),
    );

    if (result == true) {
      onRestaurantUpdated?.call();
    }
  }

  Future<void> _deleteRestaurant(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: Text(
          'Are you sure you want to delete "${restaurant.name}"? '
          'This action cannot be undone and will remove all associated data.',
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

    final restaurantService = RestaurantService.instance;

    try {
      final response = await restaurantService.deleteRestaurant(restaurant.id);

      if (response.isSuccess) {
        onRestaurantUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant deleted successfully')),
        );
      } else {
        _showErrorSnackBar(context, response.error ?? 'Unknown error');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to delete restaurant: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
    );
  }
}

class _RestaurantDetailsDialog extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantDetailsDialog({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(restaurant.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Address', restaurant.address),
            _buildInfoRow('Phone', restaurant.phone),
            _buildInfoRow(
              'Created',
              restaurant.createdAt != null
                  ? '${restaurant.createdAt!.day}/${restaurant.createdAt!.month}/${restaurant.createdAt!.year}'
                  : 'N/A',
            ),
            _buildInfoRow(
              'Team Members',
              '${restaurant.restaurantTeam.length}',
            ),
            if (restaurant.restaurantTeam.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Team Members:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...restaurant.restaurantTeam.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        member.jobType == JobType.MANAGER
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        size: 16,
                        color: member.jobType == JobType.MANAGER
                            ? Colors.orange
                            : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text('${member.name} (${member.jobType.name})'),
                      const Spacer(),
                      Chip(
                        label: Text(member.isActive ? 'Active' : 'Inactive'),
                        backgroundColor: member.isActive
                            ? Colors.green[100]
                            : Colors.orange[100],
                        labelStyle: TextStyle(
                          color: member.isActive
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EditRestaurantDialog extends StatefulWidget {
  final Restaurant restaurant;

  const _EditRestaurantDialog({required this.restaurant});

  @override
  State<_EditRestaurantDialog> createState() => _EditRestaurantDialogState();
}

class _EditRestaurantDialogState extends State<_EditRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.restaurant.name);
    _addressController = TextEditingController(text: widget.restaurant.address);
    _phoneController = TextEditingController(text: widget.restaurant.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final restaurantService = RestaurantService.instance;

    try {
      final response = await restaurantService.updateRestaurant(
        id: widget.restaurant.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant updated successfully'),
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
          content: Text('Failed to update restaurant: $e'),
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
      title: Text('Edit ${widget.restaurant.name}'),
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
          onPressed: _isLoading ? null : _updateRestaurant,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
