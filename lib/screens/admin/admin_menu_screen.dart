import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  List<AdminMenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getAdminMenuItems();
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMenuItemDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menuItems.isEmpty
              ? const Center(child: Text('No menu items found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description),
                            Text('Category: ${item.category}'),
                            Text('Price: \$${item.price.toStringAsFixed(2)}'),
                            Text(
                                'Available: ${item.isAvailable ? "Yes" : "No"}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditMenuItemDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddMenuItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final item = AdminMenuItem(
                  id: '',
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  category: categoryController.text,
                  dietaryTags: [],
                  imageUrl: 'food.jpg',
                  isFeatured: false,
                  isAvailable: true,
                  preparationTime: 15,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await ApiService.createMenuItem(item);
                Navigator.pop(context);
                _loadMenuItems();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu item added')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMenuItemDialog(AdminMenuItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final categoryController = TextEditingController(text: item.category);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final updatedItem = AdminMenuItem(
                  id: item.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  category: categoryController.text,
                  dietaryTags: item.dietaryTags,
                  imageUrl: item.imageUrl,
                  isFeatured: item.isFeatured,
                  isAvailable: item.isAvailable,
                  preparationTime: item.preparationTime,
                  createdAt: item.createdAt,
                  updatedAt: DateTime.now(),
                );
                await ApiService.updateMenuItem(item.id, updatedItem);
                Navigator.pop(context);
                _loadMenuItems();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu item updated')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(AdminMenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Delete "${item.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deleteMenuItem(item.id);
                Navigator.pop(context);
                _loadMenuItems();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu item deleted')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
