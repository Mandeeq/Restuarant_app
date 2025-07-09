import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/menu_item_model.dart';
import '../../services/api_service.dart';
import '../../components/cards/iteam_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'all';

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

  Future<void> _loadMenuItems({String? category}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await ApiService.getMenuItems(
        category: category == 'all' ? null : category,
      );
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadMenuItems(category: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadMenuItems(category: _selectedCategory),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => _onCategoryChanged(category),
                    backgroundColor: Colors.grey[200],
                    selectedColor: primaryColor,
                  ),
                );
              },
            ),
          ),

          // Menu Items
          Expanded(
            child: _buildMenuContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading menu items...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadMenuItems(category: _selectedCategory),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_menuItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No menu items found'),
            SizedBox(height: 8),
            Text('Try selecting a different category'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding),
          child: ItemCard(
            title: item.name,
            description: item.description,
            image: item.imageUrl.isNotEmpty
                ? item.imageUrl
                : 'assets/images/featured _items_1.png',
            foodType: item.category,
            price: item.price,
            priceRange: '\$' * (item.price ~/ 5 + 1),
            press: () {
              // Navigate to item details or add to cart
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.name} to cart'),
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: () {
                      // Navigate to cart
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
