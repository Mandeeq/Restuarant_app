// Admin User Model
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }
}

// Dashboard Statistics Model
class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;
  final int totalCustomers;
  final int totalMenuItems;
  final List<DailyRevenue> dailyRevenue;
  final List<CategoryStats> categoryStats;

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.totalCustomers,
    required this.totalMenuItems,
    required this.dailyRevenue,
    required this.categoryStats,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
      totalMenuItems: json['totalMenuItems'] ?? 0,
      dailyRevenue: (json['dailyRevenue'] as List?)
              ?.map((e) => DailyRevenue.fromJson(e))
              .toList() ??
          [],
      categoryStats: (json['categoryStats'] as List?)
              ?.map((e) => CategoryStats.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// Daily Revenue Model
class DailyRevenue {
  final String date;
  final double revenue;
  final int orders;

  DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: json['date'],
      revenue: (json['revenue'] ?? 0).toDouble(),
      orders: json['orders'] ?? 0,
    );
  }
}

// Category Statistics Model
class CategoryStats {
  final String category;
  final int orders;
  final double revenue;
  final double percentage;

  CategoryStats({
    required this.category,
    required this.orders,
    required this.revenue,
    required this.percentage,
  });

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      category: json['category'],
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

// Order Management Model
class AdminOrder {
  final String id;
  final String customerName;
  final String customerEmail;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String serviceType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? specialInstructions;

  AdminOrder({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.serviceType,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.specialInstructions,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['_id'],
      customerName: json['customerName'] ?? 'Unknown',
      customerEmail: json['customerEmail'] ?? '',
      items: (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      serviceType: json['serviceType'] ?? 'delivery',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveryAddress: json['deliveryAddress'],
      specialInstructions: json['specialInstructions'],
    );
  }
}

// Order Item Model
class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
    );
  }
}

// Menu Item Management Model
class AdminMenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> dietaryTags;
  final String imageUrl;
  final bool isFeatured;
  final bool isAvailable;
  final int preparationTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.dietaryTags,
    required this.imageUrl,
    required this.isFeatured,
    required this.isAvailable,
    required this.preparationTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminMenuItem.fromJson(Map<String, dynamic> json) {
    return AdminMenuItem(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'],
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      isAvailable: json['available'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
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
      'available': isAvailable,
      'preparationTime': preparationTime,
    };
  }
}

// Customer Management Model
class AdminCustomer {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastOrderDate;
  final int totalOrders;
  final double totalSpent;

  AdminCustomer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isVerified,
    required this.createdAt,
    this.lastOrderDate,
    required this.totalOrders,
    required this.totalSpent,
  });

  factory AdminCustomer.fromJson(Map<String, dynamic> json) {
    return AdminCustomer(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : null,
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }
}

// Payment Management Model
class AdminPayment {
  final String id;
  final String orderId;
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;

  AdminPayment({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    return AdminPayment(
      id: json['_id'],
      orderId: json['orderId'],
      customerName: json['customerName'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionId: json['transactionId'],
    );
  }
}
