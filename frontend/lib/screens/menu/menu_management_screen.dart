import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu/index.dart';
import 'add_edit_item_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  ItemsCategory? _selectedCategory;
  bool _hasLoadedCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    // Don't try to load if auth is still loading or already loaded
    if (authProvider.isLoading || _hasLoadedCategories) {
      return;
    }

    final restaurantId = authProvider.currentUser?.restaurant.id;
    if (restaurantId != null) {
      _hasLoadedCategories = true;
      menuProvider.loadCategories(restaurantId);
    }
  }

  void _onCategorySelected(ItemsCategory category) {
    setState(() {
      _selectedCategory = category;
    });

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.loadItems(category.id);
  }

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Appetizers, Main Courses',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  await _createCategory(nameController.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(String name) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    final restaurantId = authProvider.currentUser?.restaurant.id;
    if (restaurantId != null) {
      final success = await menuProvider.createCategory(
        name: name,
        restaurantId: restaurantId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "$name" added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(menuProvider.error ?? 'Failed to add category'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<MenuProvider, AuthProvider>(
        builder: (context, menuProvider, authProvider, child) {
          // Trigger loading when auth becomes available
          if (!authProvider.isLoading && authProvider.isLoggedIn && !_hasLoadedCategories) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCategories();
            });
          }

          if (menuProvider.isLoading && menuProvider.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              // Categories sidebar
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Categories header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category, color: Colors.deepOrange),
                          const SizedBox(width: 12),
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _showAddCategoryDialog,
                            tooltip: 'Add Category',
                          ),
                        ],
                      ),
                    ),

                    // Categories list
                    Expanded(
                      child: () {
                        print('DEBUG UI: Categories count: ${menuProvider.categories.length}');
                        print('DEBUG UI: Categories list: ${menuProvider.categories}');
                        return menuProvider.categories.isEmpty;
                      }()
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No categories yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add your first category',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: menuProvider.categories.length,
                              itemBuilder: (context, index) {
                                final category = menuProvider.categories[index];
                                final isSelected =
                                    _selectedCategory?.id == category.id;

                                return ListTile(
                                  title: Text(category.name),
                                  selected: isSelected,
                                  selectedTileColor: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  leading: Icon(
                                    Icons.restaurant_menu,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                  onTap: () => _onCategorySelected(category),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // Items main area
              Expanded(
                child: Column(
                  children: [
                    // Items header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant, color: Colors.green),
                          const SizedBox(width: 12),
                          Text(
                            _selectedCategory != null
                                ? '${_selectedCategory!.name} Items'
                                : 'Menu Items',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedCategory != null)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                              onPressed: () => _navigateToAddItem(),
                            ),
                        ],
                      ),
                    ),

                    // Items content
                    Expanded(child: _buildItemsContent()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemsContent() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        if (_selectedCategory == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Select a category',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose a category from the sidebar to view its items',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (menuProvider.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No items in ${_selectedCategory!.name}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your first menu item',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  onPressed: () => _navigateToAddItem(),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: menuProvider.items.length,
          itemBuilder: (context, index) {
            final item = menuProvider.items[index];
            return _buildItemCard(item);
          },
        );
      },
    );
  }

  Widget _buildItemCard(MenuItem item) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToEditItem(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  color: Colors.grey,
                ),
                child: item.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.white, size: 32),
                      ),
              ),
            ),

            // Item details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddItem() {
    if (_selectedCategory != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AddEditItemScreen(categoryId: _selectedCategory!.id),
        ),
      );
    }
  }

  void _navigateToEditItem(MenuItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddEditItemScreen(categoryId: item.categoryId, item: item),
      ),
    );
  }
}
