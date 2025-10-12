// lib/screens/home/featured_item_screen.dart
import 'package:flutter/material.dart';
import '../../../models/home_model.dart';
import '../../../utils/image_utils.dart';
import '../../../theme.dart'; // assuming you have theme constants like primaryColor, etc.

class FeaturedItemScreen extends StatelessWidget {
  final FeaturedItem item;

  const FeaturedItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final url = ImageUtils.getImageUrl(item.imageUrl);
    final imageProvider = (url.isNotEmpty && ImageUtils.isValidImageUrl(url))
        ? NetworkImage(url)
        : const AssetImage('assets/images/placeholder.png') as ImageProvider;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Image
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'featuredItem_${item.id}',
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
                  // Dark gradient overlay for text contrast
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
                  // Title overlay on image (optional but elegant)
                  Positioned(
                    bottom: 120,
                    left: 24,
                    right: 24,
                    child: Text(
                      item.title,
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
                  // Price overlay (subtle)
                  Positioned(
                    bottom: 80,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.85),
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
                  Navigator.pop(context); // or navigate to cart
                },
              ),
            ],
          ),

          // Content Section
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About This Offer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.subtitle.isNotEmpty
                              ? item.subtitle
                              : 'No additional details available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: bodyTextColor,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        // You can add logic here (e.g., show dialog, navigate, etc.)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Offer claimed: ${item.title}!'),
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_offer, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Claim This Offer',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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