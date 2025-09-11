import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  List<AdminMenuItem> _allMenuItems = [];
  List<AdminMenuItem> _filteredMenuItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'all',
    'starter',
    'main',
    'dessert',
    'drink',
    'special',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getAdminMenuItems();
      setState(() {
        _allMenuItems = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading menu items: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _applyFilters() {
    List<AdminMenuItem> filtered = _allMenuItems;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item.name.toLowerCase();
        final description = item.description.toLowerCase();
        final category = item.category.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) ||
               description.contains(query) ||
               category.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    setState(() {
      _filteredMenuItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Menu Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMenuItemDialog(),
            tooltip: 'Add Menu Item',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
            tooltip: 'Refresh Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, description, or category...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),
                
                // Category Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.category),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category == 'all' ? 'All Categories' : category.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Items',
                    _filteredMenuItems.length.toString(),
                    Icons.restaurant_menu,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    _filteredMenuItems.where((item) => item.isAvailable).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Featured',
                    _filteredMenuItems.where((item) => item.isFeatured).length.toString(),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMenuItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(defaultPadding),
                        itemCount: _filteredMenuItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredMenuItems[index];
                          return _buildMenuItemCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No menu items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(AdminMenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditMenuItemDialog(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCategoryColor(item.category).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(item.category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Item Details
              Row(
                children: [
                  Expanded(
                    child: _buildItemDetail(
                      'Status',
                      item.isAvailable ? 'Available' : 'Unavailable',
                      item.isAvailable ? Icons.check_circle : Icons.cancel,
                      item.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItemDetail(
                      'Featured',
                      item.isFeatured ? 'Yes' : 'No',
                      item.isFeatured ? Icons.star : Icons.star_border,
                      item.isFeatured ? Colors.orange : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildItemDetail(
                      'Prep Time',
                      '${item.preparationTime} min',
                      Icons.timer,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              // Dietary Tags
              if (item.dietaryTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: item.dietaryTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // Action Buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditMenuItemDialog(item),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(item),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetail(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'starter':
        return Colors.blue;
      case 'main':
        return Colors.green;
      case 'dessert':
        return Colors.purple;
      case 'drink':
        return Colors.orange;
      case 'special':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddMenuItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'main';
    bool isAvailable = true;
    bool isFeatured = false;
    int preparationTime = 15;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMenuItemForm(
        title: 'Add Menu Item',
        nameController: nameController,
        descriptionController: descriptionController,
        priceController: priceController,
        selectedCategory: selectedCategory,
        isAvailable: isAvailable,
        isFeatured: isFeatured,
        preparationTime: preparationTime,
        onSave: () async {
          try {
            final item = AdminMenuItem(
              id: '',
              name: nameController.text,
              description: descriptionController.text,
              price: double.tryParse(priceController.text) ?? 0,
              category: selectedCategory,
              dietaryTags: [],
              imageUrl: 'food.jpg',
              isFeatured: isFeatured,
              isAvailable: isAvailable,
              preparationTime: preparationTime,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await ApiService.createMenuItem(item);
            Navigator.pop(context);
            _loadMenuItems();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu item added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding menu item: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditMenuItemDialog(AdminMenuItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    String selectedCategory = item.category;
    bool isAvailable = item.isAvailable;
    bool isFeatured = item.isFeatured;
    int preparationTime = item.preparationTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMenuItemForm(
        title: 'Edit Menu Item',
        nameController: nameController,
        descriptionController: descriptionController,
        priceController: priceController,
        selectedCategory: selectedCategory,
        isAvailable: isAvailable,
        isFeatured: isFeatured,
        preparationTime: preparationTime,
        onSave: () async {
          try {
            final updatedItem = AdminMenuItem(
              id: item.id,
              name: nameController.text,
              description: descriptionController.text,
              price: double.tryParse(priceController.text) ?? 0,
              category: selectedCategory,
              dietaryTags: item.dietaryTags,
              imageUrl: item.imageUrl,
              isFeatured: isFeatured,
              isAvailable: isAvailable,
              preparationTime: preparationTime,
              createdAt: item.createdAt,
              updatedAt: DateTime.now(),
            );
            await ApiService.updateMenuItem(item.id, updatedItem);
            Navigator.pop(context);
            _loadMenuItems();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu item updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating menu item: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItemForm({
    required String title,
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required TextEditingController priceController,
    required String selectedCategory,
    required bool isAvailable,
    required bool isFeatured,
    required int preparationTime,
    required VoidCallback onSave,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories
                            .where((category) => category != 'all')
                            .map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: preparationTime,
                              decoration: const InputDecoration(
                                labelText: 'Preparation Time (min)',
                                border: OutlineInputBorder(),
                              ),
                              items: [5, 10, 15, 20, 25, 30].map((time) {
                                return DropdownMenuItem<int>(
                                  value: time,
                                  child: Text('$time minutes'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  preparationTime = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Available'),
                              value: isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  isAvailable = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Featured'),
                              value: isFeatured,
                              onChanged: (value) {
                                setState(() {
                                  isFeatured = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(AdminMenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deleteMenuItem(item.id);
                Navigator.pop(context);
                _loadMenuItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu item deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting menu item: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
