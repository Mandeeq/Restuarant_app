class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menuItemId'],
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      quantity: json['quantity'],
      specialInstructions: json['specialInstructions'],
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
}

class DeliveryAddress {
  final String street;
  final String city;
  final double? lat;
  final double? lng;

  DeliveryAddress({
    required this.street,
    required this.city,
    this.lat,
    this.lng,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      lat: json['coordinates']?['lat'],
      lng: json['coordinates']?['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      if (lat != null && lng != null)
        'coordinates': {
          'lat': lat,
          'lng': lng,
        },
    };
  }
}

class Order {
  final String? id;
  final String? userId;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final String serviceType; // 'delivery', 'takeaway', 'dine-in'
  final DeliveryAddress? deliveryAddress;
  final String paymentMethod; // 'mpesa', 'card', 'cash'
  final String paymentStatus; // 'pending', 'completed', 'failed'
  final String
      orderStatus; // 'pending', 'confirmed', 'preparing', 'out-for-delivery', 'delivered', 'cancelled'
  final String? promoCode;
  final double discountApplied;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final String? review;

  Order({
    this.id,
    this.userId,
    required this.items,
    required this.totalAmount,
    this.deliveryFee = 0,
    required this.serviceType,
    this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.orderStatus = 'pending',
    this.promoCode,
    this.discountApplied = 0,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.review,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      userId: json['user'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] is int)
          ? (json['totalAmount'] as int).toDouble()
          : json['totalAmount'].toDouble(),
      deliveryFee: (json['deliveryFee'] is int)
          ? (json['deliveryFee'] as int).toDouble()
          : (json['deliveryFee'] ?? 0).toDouble(),
      serviceType: json['serviceType'],
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      orderStatus: json['orderStatus'] ?? 'pending',
      promoCode: json['promoCode'],
      discountApplied: (json['discountApplied'] ?? 0).toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      rating: json['rating']?.toDouble(),
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (userId != null) 'user': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'serviceType': serviceType,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress!.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      if (promoCode != null) 'promoCode': promoCode,
      'discountApplied': discountApplied,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
    };
  }

  // Helper method to create a simple order for backward compatibility
  factory Order.simple({
    required String title,
    required double price,
    required int numOfItem,
  }) {
    return Order(
      items: [
        OrderItem(
          menuItemId: '',
          name: title,
          price: price,
          quantity: numOfItem,
        ),
      ],
      totalAmount: price * numOfItem,
      serviceType: 'takeaway',
      paymentMethod: 'cash',
    );
  }
}
