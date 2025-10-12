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
    try {
  // Keep raw image path from backend; ImageUtils.getImageProvider will
  // resolve to a NetworkImage using baseUrl or fall back to a placeholder.
  String imageUrl = json['imageUrl'] ?? '';

      return MenuItem(
        id: json['_id'] ?? '',
        name: json['name'] ?? 'Unknown Item',
        description: json['description'] ?? '',
        price: (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : (json['price'] ?? 0.0).toDouble(),
        category: json['category'] ?? 'Other',
        dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
        imageUrl: imageUrl,
        isFeatured: json['isFeatured'] ?? false,
        preparationTime: json['preparationTime'] ?? 15,
        available: json['available'] ?? true,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt']) 
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing MenuItem: $e');
      print('❌ JSON data: $json');
      // Return a default menu item instead of throwing
      return MenuItem(
        id: json['_id'] ?? 'error',
        name: json['name'] ?? 'Error Loading Item',
        description: 'This item could not be loaded properly',
        price: 0.0,
        category: 'Error',
        dietaryTags: [],
        imageUrl: ImageUtils.getDefaultImageUrl(),
        isFeatured: false,
        preparationTime: 15,
        available: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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
