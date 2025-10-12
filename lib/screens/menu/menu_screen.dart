import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/menu_item_model.dart';
import '../../utils/image_utils.dart';
import '../../services/api_service.dart';
import '../payment/cart_page.dart';
import 'menu_item_screen.dart';

class MenuScreen extends StatefulWidget {
  final List<String> cartItems;
  final Function(String) onAddToCart;

  const MenuScreen({
    super.key,
    required this.cartItems,
    required this.onAddToCart,
  });

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

  // Helper method to build star rating widget
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(1, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 12,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCategoryChip(
        BuildContext context, String category, bool isSelected) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => _onCategoryChanged(category),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.red.shade200,
                  width: 1.2,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return buildCategoryChip(context, category, isSelected);
              },
            ),
          ),

          // Menu Items List
          Expanded(child: _buildMenuContent(context)),
        ],
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
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
        child: Text("No menu items found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            elevation: 0.3,
            color: Colors.grey[100],
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuItemScreen(
                      menuItem: item,
                      onAddToCart: widget.onAddToCart,
                      cartItems: widget.cartItems,
                    ),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  Container(
                    width: 140,
                    height: 145,
                    child: ClipRRect(
                      child: Image(
                        image: ImageUtils.getImageProvider(item.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood,
                                size: 40, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Food Name
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Rating and Reviews
                              Row(
                                children: [
                                  _buildRatingStars(4.5),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.5(30)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Description
                          // Description with fixed min height for 3 lines
                          Container(
                            constraints: BoxConstraints(
                                minHeight: 36), // Minimum height for 3 lines
                            child: Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Price and Add Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\Ksh ${item.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),

                              // Add Button
                              InkWell(
                                onTap: () {
                                  widget.onAddToCart(item.name);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Added ${item.name} to cart'),
                                      action: SnackBarAction(
                                        label: 'View Cart',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CartPage(
                                                  cartItems: widget.cartItems),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '+ Add',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
