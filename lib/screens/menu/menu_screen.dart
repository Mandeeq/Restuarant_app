import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/menu_item_model.dart';
import '../../services/api_service.dart';

import '../payment/cart_page.dart';
import 'menu_item_screen.dart'; // Make sure the path is correct

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

  @override
  Widget build(BuildContext context) {
    Widget buildCategoryChip(BuildContext context, String category, bool isSelected) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(category.toUpperCase()),
          selected: isSelected,
          onSelected: (_) => _onCategoryChanged(category),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.grey[200],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ Category Filter with Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration( // <--- Add this decoration
              color: Theme.of(context).canvasColor, // Or your specific background color for this bar
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400, // Choose a subtle color for the border
                  width: 1.0, // Adjust width as needed, 1.0 is usually good for a subtle line
                ),
              ),
              // Optional: Add a subtle shadow for more depth
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.2),
              //     spreadRadius: 1,
              //     blurRadius: 3,
              //     offset: Offset(0, 2), // changes position of shadow
              //   ),
              // ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                // Using the extracted widget or method as previously discussed
                return buildCategoryChip(context, category, isSelected); // Or CategoryChipItem(...)
              },
            ),
          ),

          // ✅ Menu Items
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

    // ✅ Modern grid layout with proper sizing to prevent overflow
    return GridView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: 0.8, // Increased height to prevent overflow
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return GestureDetector(
          onTap: () {
            widget.onAddToCart(item.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${item.name} to cart'),
                action: SnackBarAction(
                  label: 'View Cart',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CartPage(cartItems: widget.cartItems),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: SizedBox(
            height: 280, // Fixed height to prevent overflow
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // 👉 Navigate to detail screen when tapping card (not the button)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Image with fixed height
                    SizedBox(
                      height: 100, // Reduced height to give more space for content
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Image loading error for ${item.name}: $error');
                            print('❌ Image URL: ${item.imageUrl}');
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
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
                    // ✅ Content with compact spacing
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with single line constraint
                            Text(
                              item.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Slightly smaller title
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2), // Reduced spacing
                            // Description with strict line limit
                            Expanded(
                              child: Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10, // Even smaller font to fit better
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2), // Reduced spacing
                            // Price
                            Text(
                              "\$${item.price.toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13, // Slightly smaller price
                              ),
                            ),
                            // const SizedBox(height: 2), // Reduced spacing
                            // Order Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary, // ✅ fill with primary
                              foregroundColor: Colors.white, // ✅ text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 28),
                            ),
                            onPressed: () {
                              widget.onAddToCart(item.name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${item.name} to cart'),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CartPage(cartItems: widget.cartItems),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Order",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
