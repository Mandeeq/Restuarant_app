import '../utils/image_utils.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> dietaryTags;
  final String imageUrl;
  final bool isFeatured;
  final int preparationTime;
  final bool available;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.dietaryTags,
    required this.imageUrl,
    required this.isFeatured,
    required this.preparationTime,
    required this.available,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Construct full image URL from backend using utility
    String imageUrl = ImageUtils.getImageUrl(json['imageUrl']);

    return MenuItem(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      category: json['category'],
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      imageUrl: imageUrl,
      isFeatured: json['isFeatured'] ?? false,
      preparationTime: json['preparationTime'] ?? 15,
      available: json['available'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'dietaryTags': dietaryTags,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'preparationTime': preparationTime,
      'available': available,
    };
  }
}
