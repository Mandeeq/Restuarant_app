// lib/screens/home/offer_item_screen.dart
import 'package:flutter/material.dart';
import '../../../models/home_model.dart';
import '../../../utils/image_utils.dart';
import '../../../theme.dart'; // Make sure this exports: primaryColor, backgroundColor, titleColor, bodyTextColor, defaultPadding

class OfferItemScreen extends StatelessWidget {
  final Offer offer;

  const OfferItemScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final url = ImageUtils.getImageUrl(offer.imageUrl);
    final imageProvider = (url.isNotEmpty && ImageUtils.isValidImageUrl(url))
        ? NetworkImage(url) as ImageProvider
        : const AssetImage('assets/images/placeholder.png');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero SliverAppBar with full-bleed image
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  Hero(
                    tag: 'offer_${offer.id}',
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.local_offer,
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
                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Offer title overlay
                  Positioned(
                    bottom: 120,
                    left: 24,
                    right: 24,
                    child: Text(
                      offer.title,
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
                  // "Limited Offer" badge
                  Positioned(
                    bottom: 80,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LIMITED TIME',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
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
                  child: Icon(Icons.favorite_border, color: primaryColor),
                ),
                onPressed: () {
                  // Optional: Add to favorites
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
                          'Offer Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          offer.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: bodyTextColor,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding),

                  // Primary CTA Button
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
                        elevation: 3,
                      ),
                      onPressed: () {
                        // Trigger offer claim logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Offer claimed: ${offer.title}!'),
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        // Optionally: Navigator.push(...) or show dialog
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.local_offer, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Redeem This Offer',
                            style: TextStyle(
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