import 'menu_item_model.dart';

class CartItem {
  final String id;
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;
  final MenuItem? menuItem;

  CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
    this.menuItem,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      menuItemId: json['menuItemId'],
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      quantity: json['quantity'],
      specialInstructions: json['specialInstructions'],
      menuItem:
          json['menuItem'] != null ? MenuItem.fromJson(json['menuItem']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      if (specialInstructions != null)
        'specialInstructions': specialInstructions,
    };
  }

  CartItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? specialInstructions,
    MenuItem? menuItem,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      menuItem: menuItem ?? this.menuItem,
    );
  }
}

class Cart {
  final String? id;
  final String? userId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    this.id,
    this.userId,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    final items = itemsJson.map((item) => CartItem.fromJson(item)).toList();

    return Cart(
      id: json['_id'],
      userId: json['userId'],
      items: items,
      subtotal: (json['subtotal'] is int)
          ? (json['subtotal'] as int).toDouble()
          : json['subtotal'].toDouble(),
      deliveryFee: (json['deliveryFee'] is int)
          ? (json['deliveryFee'] as int).toDouble()
          : json['deliveryFee']?.toDouble() ?? 0,
      total: (json['total'] is int)
          ? (json['total'] as int).toDouble()
          : json['total'].toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
  }

  // Helper methods
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
