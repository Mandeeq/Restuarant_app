import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/menu_item_model.dart';
import '../../utils/image_utils.dart';
import '../../services/api_service.dart';
import '../payment/cart_page.dart';
import 'menu_item_screen.dart';

class MenuScreen extends StatefulWidget {
  final List<MenuItem> cartItems;
  final Function(MenuItem) onAddToCart;

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
    Widget buildCategoryChip(BuildContext context, String category,
        bool isSelected) {
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
          selectedColor: Theme
              .of(context)
              .colorScheme
              .primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme
                .of(context)
                .colorScheme
                .primary,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor:
          Theme
              .of(context)
              .colorScheme
              .primary
              .withOpacity(0.2),
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
      padding: EdgeInsets.all(defaultPadding), // already good
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return Container(
          // ✅ Increased vertical spacing (was 4 → now 8)
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
          BoxShadow(color: Colors.black12,
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // ✅ for proper ripple clipping
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MenuItemScreen(
                        menuItem: item,
                        onAddToCart: widget.onAddToCart,
                      ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image — ✅ Made square (140x140) for consistency
                SizedBox(
                  width: 140,
                  height: 140,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Content Area
                Expanded(
                  // ✅ Use defaultPadding (e.g., 16) instead of hardcoded 12
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food Name & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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

                        // ✅ Slightly increased gap (was 6 → 8)
                        const SizedBox(height: 8),

                        // Description
                        // ✅ Keep min height, but use consistent line height
                        Container(
                          constraints: const BoxConstraints(minHeight: 36),
                          child: Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.4, // slightly tighter than 1.3
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ Slightly increased gap (was 8 → 10)
                        const SizedBox(height: 10),

                        // Price and Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ksh ${item.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                // ✅ Use primaryColor or theme color instead of green[800]
                                color: primaryColor,
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                widget.onAddToCart(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${item.name} to cart'),
                                    backgroundColor: primaryColor,
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const CartPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, // ✅ slightly wider
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
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
        );
      },
    );
  }
}