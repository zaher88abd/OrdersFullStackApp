import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  await initHiveForFlutter();
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      'http://localhost:4000', // GraphQL backend endpoint
    );

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Restaurant Admin Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const DashboardHome(),
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const UserManagementPage(),
    const RestaurantManagementPage(),
    const OrderManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('User Management'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant),
                label: Text('Restaurants'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long),
                label: Text('Orders'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

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

class RestaurantManagementPage extends StatelessWidget {
  const RestaurantManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Restaurant Management - Coming Soon'),
    );
  }
}

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Order Management - Coming Soon'),
    );
  }
}

class UserAccountTable extends StatelessWidget {
  const UserAccountTable({super.key});

  static const String getAllUsersQuery = '''
    query GetAllUsers {
      restaurants {
        id
        name
        restaurantTeam {
          uuid
          name
          jobType
          isActive
          createdAt
          updatedAt
        }
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(getAllUsersQuery),
        pollInterval: const Duration(seconds: 30),
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${result.exception.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: refetch,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final restaurants = result.data?['restaurants'] as List?;
        if (restaurants == null || restaurants.isEmpty) {
          return const Center(child: Text('No restaurants found'));
        }

        // Flatten all restaurant team members into a single list
        final allUsers = <Map<String, dynamic>>[];
        for (final restaurant in restaurants) {
          final restaurantTeam = restaurant['restaurantTeam'] as List?;
          if (restaurantTeam != null) {
            for (final user in restaurantTeam) {
              allUsers.add({
                ...user,
                'restaurantName': restaurant['name'],
                'restaurantId': restaurant['id'],
              });
            }
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Users: ${allUsers.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    ElevatedButton.icon(
                      onPressed: refetch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Job Type')),
                        DataColumn(label: Text('Restaurant')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Created At')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: allUsers.map((user) {
                        final isActive = user['isActive'] as bool;
                        final createdAt = DateTime.tryParse(user['createdAt'] ?? '');
                        
                        return DataRow(
                          cells: [
                            DataCell(Text(user['name'] ?? 'N/A')),
                            DataCell(Text(user['jobType'] ?? 'N/A')),
                            DataCell(Text(user['restaurantName'] ?? 'N/A')),
                            DataCell(
                              Chip(
                                label: Text(isActive ? 'Active' : 'Disabled'),
                                backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
                                labelStyle: TextStyle(
                                  color: isActive ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(createdAt != null 
                                ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                                : 'N/A'
                              ),
                            ),
                            DataCell(
                              UserActionButtons(
                                user: user,
                                onUserUpdated: refetch,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserActionButtons extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onUserUpdated;

  const UserActionButtons({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  static const String updateUserMutation = '''
    mutation UpdateUser(\$uuid: String!, \$input: UpdateRestaurantTeamInput!) {
      updateRestaurantTeam(uuid: \$uuid, input: \$input) {
        uuid
        name
        isActive
      }
    }
  ''';

  static const String deleteUserMutation = '''
    mutation DeleteUser(\$uuid: String!) {
      deleteRestaurantTeam(uuid: \$uuid)
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final isActive = user['isActive'] as bool;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Mutation(
          options: MutationOptions(
            document: gql(updateUserMutation),
            onCompleted: (data) {
              onUserUpdated?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isActive 
                    ? 'User account disabled successfully'
                    : 'User account activated successfully'
                  ),
                ),
              );
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error?.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return IconButton(
              onPressed: result?.isLoading == true ? null : () {
                runMutation({
                  'uuid': user['uuid'],
                  'input': {'isActive': !isActive},
                });
              },
              icon: Icon(
                isActive ? Icons.block : Icons.check_circle,
                color: isActive ? Colors.orange : Colors.green,
              ),
              tooltip: isActive ? 'Disable Account' : 'Activate Account',
            );
          },
        ),
        Mutation(
          options: MutationOptions(
            document: gql(deleteUserMutation),
            onCompleted: (data) {
              onUserUpdated?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User account deleted successfully'),
                ),
              );
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error?.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return IconButton(
              onPressed: result?.isLoading == true ? null : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete User Account'),
                    content: Text('Are you sure you want to delete ${user['name']}\'s account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          runMutation({'uuid': user['uuid']});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Account',
            );
          },
        ),
      ],
    );
  }
}