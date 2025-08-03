class User {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final bool phoneVerified;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
    this.phoneVerified = false,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      phoneVerified: json['phoneVerified'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      message: json['message'],
    );
  }
}
