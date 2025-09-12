class FeaturedItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double price;

  FeaturedItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
  });

  factory FeaturedItem.fromJson(Map<String, dynamic> json) {
    return FeaturedItem(
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()),
    );
  }
}

class PopularItem {
  final String name;
  final String imageUrl;
  final double price;

  PopularItem({required this.name, required this.imageUrl, required this.price});

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    return PopularItem(
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: double.parse(json['price'].toString()),
    );
  }
}

class Offer {
  final String title;
  final String description;
  final String imageUrl;

  Offer({required this.title, required this.description, required this.imageUrl});

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class Testimonial {
  final String user;
  final String comment;
  final int rating;

  Testimonial({required this.user, required this.comment, required this.rating});

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      user: json['user'],
      comment: json['comment'],
      rating: json['rating'],
    );
  }
}
