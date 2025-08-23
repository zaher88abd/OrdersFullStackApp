import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

class RestaurantManagementPage extends StatefulWidget {
  const RestaurantManagementPage({super.key});

  @override
  State<RestaurantManagementPage> createState() => _RestaurantManagementPageState();
}

class _RestaurantManagementPageState extends State<RestaurantManagementPage> {
  final RestaurantService _restaurantService = RestaurantService.instance;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;
  String? _activeRestaurantCode;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final restaurants = await _restaurantService.getRestaurants();
      
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _activateRestaurant(Restaurant restaurant) async {
    if (restaurant.restaurantCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This restaurant does not have a restaurant code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _activeRestaurantCode = restaurant.restaurantCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activated restaurant: ${restaurant.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deactivateRestaurant() async {
    setState(() {
      _activeRestaurantCode = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deactivated restaurant'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, size: 32),
              const SizedBox(width: 16),
              const Text(
                'Restaurant Selection',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_activeRestaurantCode != null) ...[
                Chip(
                  label: Text('Active: $_activeRestaurantCode'),
                  backgroundColor: Colors.green.shade100,
                  avatar: const Icon(Icons.check_circle, size: 18),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _deactivateRestaurant,
                  icon: const Icon(Icons.stop),
                  label: const Text('Deactivate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else ...[
                const Chip(
                  label: Text('No Active Restaurant'),
                  backgroundColor: Colors.grey,
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading restaurants',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_error!),
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
            const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No restaurants found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Create your first restaurant to get started'),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              'Available Restaurants (${_restaurants.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _restaurants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                final isActive = restaurant.restaurantCode == _activeRestaurantCode;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      isActive ? Icons.check : Icons.restaurant,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    restaurant.name,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${restaurant.address} • ${restaurant.phone}'),
                      const SizedBox(height: 4),
                      if (restaurant.restaurantCode != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Code: ${restaurant.restaurantCode}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Row(
                          children: [
                            Icon(Icons.warning, size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'No restaurant code',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (restaurant.restaurantCode != null) ...[
                        if (isActive) ...[
                          ElevatedButton(
                            onPressed: _deactivateRestaurant,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Deactivate'),
                          ),
                        ] else ...[
                          ElevatedButton(
                            onPressed: () => _activateRestaurant(restaurant),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Activate'),
                          ),
                        ],
                      ] else ...[
                        ElevatedButton(
                          onPressed: null,
                          child: const Text('No Code'),
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}