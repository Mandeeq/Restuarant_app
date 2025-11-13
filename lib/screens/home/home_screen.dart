import 'package:flutter/material.dart';
import '../../theme.dart';
// order_details import removed: navigation goes to specific category detail screens
import 'featured/featured_item_screen.dart';
import 'offers/offer_item_screen.dart';
import 'popular/popular_item_screen.dart';
import '../../services/home_service.dart';
import '../../services/api_service.dart';
import '../menu/menu_item_screen.dart';
import '../../models/home_model.dart';
import '../../utils/image_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper to convert a relative/possibly-empty image path to an ImageProvider.
  // Uses NetworkImage when the constructed URL looks valid, otherwise falls back
  // to a bundled placeholder asset to avoid passing invalid URLs to NetworkImage.
  ImageProvider _imageProvider(String? imagePath) {
    final url = ImageUtils.getImageUrl(imagePath);
    if (url.isNotEmpty && ImageUtils.isValidImageUrl(url)) {
      return NetworkImage(url);
    }
    return const AssetImage('assets/images/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    final homeService = HomeService();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    // Background image
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/big_2.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Title + Location
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qaffee Point',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 42,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Everyone\'s Living Room',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Kampala • We Are Open',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
              backgroundColor: primaryColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // 🔹 Order Options (still static for now)
              //_buildOrderOptions(context),

              // 🔹 Featured Section
              _buildSectionTitle(context, "FEATURED TODAY"),
              FutureBuilder<List<FeaturedItem>>(
                future: homeService.fetchFeaturedItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No featured items available");
                  }
                  return Column(
                    children: snapshot.data!
                        .map((item) => _buildFeaturedCard(context, item))
                        .toList(),
                  );
                },
              ),

              // 🔹 Special Offers
              _buildSectionTitle(context, "SPECIAL OFFERS"),
              FutureBuilder<List<Offer>>(
                future: homeService.fetchOffers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No offers available");
                  }
                  return Column(
                    children: snapshot.data!
                        .map((offer) => _buildOfferCard(context, offer))
                        .toList(),
                  );
                },
              ),

              // 🔹 Popular Items
              _buildSectionTitle(context, "POPULAR ITEMS"),
              FutureBuilder<List<PopularItem>>(
                future: homeService.fetchPopularItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No popular items available");
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: snapshot.data!
                          .map((item) => _buildPopularCard(context, item))
                          .toList(),
                    ),
                  );
                },
              ),

              // 🔹 Testimonials
              _buildSectionTitle(context, "WHAT PEOPLE SAY"),
              FutureBuilder<List<Testimonial>>(
                future: homeService.fetchTestimonials(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No testimonials available");
                  }
                  return Column(
                    children: snapshot.data!
                        .map((t) => _buildTestimonialCard(context, t))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Helper Widgets ----------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: bodyTextColor,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  // Widget _buildOrderOptions(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         _buildActionCard(context,
  //             icon: Icons.coffee,
  //             label: "Coffee",
  //             color: const Color(0xFF6F4E37)),
  //         _buildActionCard(context,
  //             icon: Icons.breakfast_dining,
  //             label: "Breakfast",
  //             color: const Color(0xFFFF9F1C)),
  //         _buildActionCard(context,
  //             icon: Icons.cake,
  //             label: "Pastries",
  //             color: const Color(0xFFFF6B6B)),
  //         _buildActionCard(context,
  //             icon: Icons.local_drink, label: "Specialty", color: primaryColor),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildFeaturedCard(BuildContext context, FeaturedItem item) {
    return GestureDetector(
      onTap: () async {
        // If the featured item references a menu item id, open the menu detail
        if (item.id.isNotEmpty) {
          try {
            final menuItem = await ApiService.getMenuItem(item.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MenuItemScreen(menuItem: menuItem),
              ),
            );
            return;
          } catch (_) {
            // ignore and open the featured screen fallback
          }
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FeaturedItemScreen(item: item)));
      },
                child: Container(
        height: 180,
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
      image: DecorationImage(
        image: _imageProvider(item.imageUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(item.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70)),
              Text("Ksh. ${item.price}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Text section with extra horizontal padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // ← Added padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ← Changed to start for better alignment
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      offer.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      offer.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                            ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Limited Time Offer',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12), // Slightly reduced gap for balance
            // Image section (no extra padding, stays flush)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 160,
                height: 160,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OfferItemScreen(offer: offer))),
                  child: Image(
                    image: _imageProvider(offer.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPopularCard(BuildContext context, PopularItem item) {
    double cardWidth = MediaQuery.of(context).size.width * 0.6; // 40% of screen

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PopularItemScreen(item: item))),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image(
                  image: _imageProvider(item.imageUrl),
                  height: 220,
                  width: 320,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text("Ksh. ${item.price}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, Testimonial t) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  gradient: LinearGradient(
    colors: [
      Colors.grey[50]!,
      Colors.grey[100]!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  boxShadow: [
    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
  ],
),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("⭐" * t.rating,
            style: const TextStyle(color: Colors.amber, fontSize: 16)),
        const SizedBox(height: 6),
        Text(t.comment,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black87)),
        const SizedBox(height: 6),
        Text("- ${t.user}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, color: Colors.black54)),
      ],
    ),
  );
}

  Widget _buildActionCard(BuildContext context,
    {required IconData icon, required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.all(10),
    // Remove alignment or set to top-left if needed; not necessary here
    decoration: BoxDecoration(
      color: Colors.white60,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 👈 This makes children align to the left
      mainAxisSize: MainAxisSize.min, // Prevents unnecessary vertical stretch
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        // const SizedBox(height: 8),
        // Text(
        //   label,
        //   style: Theme.of(context)
        //       .textTheme
        //       .bodyMedium
        //       ?.copyWith(fontWeight: FontWeight.w500),
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
      ],
    ),
  );
}
}