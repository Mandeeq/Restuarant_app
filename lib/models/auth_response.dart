import 'user_model.dart';

class AuthResponse {
  final String token;
  final User user;
  final String message;
  final bool success;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
    this.success = true,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'message': message,
      'success': success,
    };
  }
}