// lib/screens/home/popular_item_screen.dart
import 'package:flutter/material.dart';
import '../../../models/home_model.dart';
import '../../../utils/image_utils.dart';
import '../../../theme.dart'; // Ensure this exports: primaryColor, backgroundColor, titleColor, bodyTextColor, defaultPadding

class PopularItemScreen extends StatelessWidget {
  final PopularItem item;

  const PopularItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final url = ImageUtils.getImageUrl(item.imageUrl);
    final imageProvider = (url.isNotEmpty && ImageUtils.isValidImageUrl(url))
        ? NetworkImage(url) as ImageProvider
        : const AssetImage('assets/images/placeholder.png');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero SliverAppBar with food image
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image for smooth transition
                  Hero(
                    tag: 'popular_${item.id}',
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark gradient for text contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Item name overlay
                  Positioned(
                    bottom: 120,
                    left: 24,
                    right: 24,
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Price badge
                  Positioned(
                    bottom: 80,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Ksh. ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
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
                child: Icon(Icons.arrow_back, color: primaryColor),
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
                  child: Icon(Icons.shopping_cart, color: primaryColor),
                ),
                onPressed: () {
                  // Navigate to cart or add item
                },
              ),
            ],
          ),

          // Content: Description + CTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About This Dish',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        // Text(
                        //   item.description ?? 'Delicious and freshly prepared.',
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     color: bodyTextColor,
                        //     height: 1.6,
                        //   ),
                        //   textAlign: TextAlign.justify,
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        // Add to cart logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Added to cart: ${item.name}!'),
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: defaultPadding * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}