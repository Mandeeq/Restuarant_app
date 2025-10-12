// lib/screens/menu/menu_item_screen.dart
import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../theme.dart';
import '../../utils/image_utils.dart';

class MenuItemScreen extends StatelessWidget {
  final MenuItem menuItem;
  final Function(String)? onAddToCart;
  final List<String> cartItems;

  const MenuItemScreen({
    super.key,
    required this.menuItem,
    this.onAddToCart,
    this.cartItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Image
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  Hero(
                    tag: 'menuItemImage_${menuItem.id}',
                    child: Image(
                      image: ImageUtils.getImageProvider(menuItem.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Log and show a placeholder when image fails
                        // ignore: avoid_print
                        print('❌ Image loading error for ${menuItem.name}: $error');
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
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
                  // Gradient overlay for better text readability
                  // Container(
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.bottomCenter,
                  //       end: Alignment.topCenter,
                  //       colors: [
                  //         backgroundColor.withOpacity(0.9),
                  //         Colors.transparent,
                  //         Colors.transparent,
                  //         Colors.transparent,
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: primaryColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart, color: primaryColor),
                ),
                onPressed: () {
                  // Navigate to cart
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          menuItem.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // Category and Price Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                menuItem.category.toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "\Ksh ${menuItem.price.toStringAsFixed(2)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // Description Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: Border(left: BorderSide(color: primaryColor, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: titleColor,
                                    // color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          menuItem.description.isNotEmpty
                              ? menuItem.description
                              : "No description available.",
                          style: TextStyle(
                            fontSize: 12,
                            color: bodyTextColor,
                            // color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // Dietary Tags Section (if available)
                  if (menuItem.dietaryTags.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: primaryColor, width: 4)),
                    ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dietary Information",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: menuItem.dietaryTags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                  ],

                  // Preparation Time Section
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: primaryColor, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.timer,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Preparation Time",
                              style: TextStyle(
                                color: bodyTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              "${menuItem.preparationTime} minutes",
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 12,
                                
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding * 2),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: defaultPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (onAddToCart != null) {
                          onAddToCart!(menuItem.name);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${menuItem.name} to cart'),
                            backgroundColor: primaryColor,
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_checkout, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Add to Cart - \Ksh. ${menuItem.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
