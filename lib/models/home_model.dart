class FeaturedItem {
  final String id; // id from backend (could be menuItemId or featured record id)
  final String title;
  final String subtitle;
  final String imageUrl;
  final double price;

  FeaturedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
  });

  factory FeaturedItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'] ?? '';
    final id = rawId?.toString() ?? '';
    final title = (json['title'] ?? '') as String;
    final subtitle = (json['subtitle'] ?? '') as String;
    final imageUrl = (json['imageUrl'] ?? '') as String;
    double price = 0.0;
    try {
      price = json['price'] != null ? double.parse(json['price'].toString()) : 0.0;
    } catch (_) {
      price = 0.0;
    }

    return FeaturedItem(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      price: price,
    );
  }
}

class PopularItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String? category;

  PopularItem({required this.id, required this.name, required this.imageUrl, required this.price, this.category});

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'] ?? '';
    final id = rawId?.toString() ?? '';
    final name = (json['name'] ?? '') as String;
    final imageUrl = (json['imageUrl'] ?? '') as String;
    double price = 0.0;
    try {
      price = json['price'] != null ? double.parse(json['price'].toString()) : 0.0;
    } catch (_) {
      price = 0.0;
    }
    final category = json['category'] != null ? json['category'].toString() : null;

    return PopularItem(id: id, name: name, imageUrl: imageUrl, price: price, category: category);
  }
}

class Offer {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double? discountPercentage;

  Offer({required this.id, required this.title, required this.description, required this.imageUrl, this.discountPercentage});

  factory Offer.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'] ?? '';
    final id = rawId?.toString() ?? '';
    final title = (json['title'] ?? '') as String;
    final description = (json['description'] ?? '') as String;
    final imageUrl = (json['imageUrl'] ?? '') as String;
    double? discount;
    if (json['discountPercentage'] != null) {
      try {
        discount = double.parse(json['discountPercentage'].toString());
      } catch (_) {
        discount = null;
      }
    }

    return Offer(id: id, title: title, description: description, imageUrl: imageUrl, discountPercentage: discount);
  }
}

class Testimonial {
  final String user;
  final String comment;
  final int rating;

  Testimonial({required this.user, required this.comment, required this.rating});

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] ?? '') as String;
    final comment = (json['comment'] ?? '') as String;
    final rating = (json['rating'] is int) ? json['rating'] as int : int.tryParse(json['rating']?.toString() ?? '') ?? 0;

    return Testimonial(user: user, comment: comment, rating: rating);
  }
}
