import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/menu_item_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/admin_models.dart';
import '../models/cart_model.dart';
import '../models/auth_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Use your computer IP address (same one used in MongoDB Compass/Postman)
  static final baseUrl = "${dotenv.env['baseUrl'] ?? ""}/api";

  // Connection timeout settings
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Store authentication token
  static String? _authToken;
  static User? _currentUser;
  static bool _isConnected = false;

  // Getters
  static String? get authToken => _authToken;
  static User? get currentUser => _currentUser;
  static bool get isAuthenticated => _authToken != null;
  static bool get isConnected => _isConnected;

  // Set authentication data
  static void setAuthData(String token, User user) {
    _authToken = token;
    _currentUser = user;
  }

  // Clear authentication data
  static void clearAuthData() {
    _authToken = null;
    _currentUser = null;
  }

  // Get headers with authentication
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Test connection with better error handling
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(connectionTimeout);

      _isConnected = response.statusCode == 200;

      return _isConnected;
    } catch (e) {
      _isConnected = false;

      return false;
    }
  }

  // Generic HTTP request handler with retry logic
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await request().timeout(receiveTimeout);
        return response;
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          throw Exception('Request failed after $maxRetries attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw Exception('Request failed');
  }

  // Authentication endpoints
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            if (phone != null) 'phone': phone,
          }),
        ));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthData(authResponse.token, authResponse.user);

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Registration failed';

      throw Exception(message);
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthData(authResponse.token, authResponse.user);

      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Login failed';

      throw Exception(message);
    }
  }

  static Future<User> getCurrentUser() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/auth/me'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['data']);
      _currentUser = user;

      return user;
    } else {
      throw Exception('Failed to get current user');
    }
  }

  // Menu endpoints
  static Future<List<MenuItem>> getMenuItems({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

      final uri =
          Uri.parse('$baseUrl/menu').replace(queryParameters: queryParams);

      final response =
          await _makeRequest(() => http.get(uri, headers: _headers));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different response structures
        List<dynamic> items = [];
        if (data['items'] != null) {
          items = data['items'];
        } else if (data['data'] != null && data['data']['items'] != null) {
          items = data['data']['items'];
        } else if (data['data'] != null && data['data'] is List) {
          items = data['data'];
        } else {
          return []; // Return empty list instead of throwing
        }

        if (items.isEmpty) {
          return [];
        }

        final menuItems = items
            .map((json) {
              try {
                final item = MenuItem.fromJson(json);

                return item;
              } catch (e) {
                return null;
              }
            })
            .where((item) => item != null)
            .cast<MenuItem>()
            .toList();

        return menuItems;
      } else {
        throw Exception('Failed to fetch menu items');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<MenuItem> getMenuItem(String id) async {
    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/menu/$id'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final menuItem = MenuItem.fromJson(data['data']);

      return menuItem;
    } else {
      throw Exception('Failed to fetch menu item');
    }
  }

  // Order endpoints
  static Future<Order> createOrder(Order order) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/orders'),
          headers: _headers,
          body: jsonEncode(order.toJson()),
        ));

    if (response.statusCode == 201) {
      print('Response body: ${response.body}');
      final data = jsonDecode(response.body);
      final createdOrder = Order.fromJson(data['data']);

      return createdOrder;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to create order';

      throw Exception(message);
    }
  }

  static Future<List<Order>> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final uri =
        Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);

    final response = await _makeRequest(() => http.get(uri, headers: _headers));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<dynamic> orders = [];
      if (data is List) {
        // Backend returns orders directly as array
        orders = data;
      } else if (data['data'] != null && data['data'] is List) {
        // Backend returns orders in data field as array
        orders = data['data'];
      } else if (data['data'] != null && data['data']['orders'] != null) {
        // Backend returns orders in data.orders field
        orders = data['data']['orders'];
      } else {
        return [];
      }

      final orderList = <Order>[];

      for (int i = 0; i < orders.length; i++) {
        try {
          final orderJson = orders[i];

          final order = Order.fromJson(orderJson);
          orderList.add(order);
        } catch (e) {}
      }

      return orderList;
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  static Future<Order> getOrder(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/orders/$id'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);

      return order;
    } else {
      throw Exception('Failed to fetch order');
    }
  }

  static Future<Order> updateOrderStatus(String id, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/orders/$id/status'),
          headers: _headers,
          body: jsonEncode({'status': status}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);

      return order;
    } else {
      throw Exception('Failed to update order status');
    }
  }

  // Cart endpoints
  static Future<Cart> getCart() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/cart'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = Cart.fromJson(data['data']);

      return cart;
    } else {
      throw Exception('Failed to fetch cart');
    }
  }

  static Future<Cart> addToCart(String menuItemId, int quantity) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/cart/add'),
          headers: _headers,
          body: jsonEncode({
            'menuItemId': menuItemId,
            'quantity': quantity,
          }),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = Cart.fromJson(data['data']);

      return cart;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to add to cart';

      throw Exception(message);
    }
  }

  static Future<Cart> updateCartItem(String itemId, int quantity) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/cart/items/$itemId'),
          headers: _headers,
          body: jsonEncode({'quantity': quantity}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = Cart.fromJson(data['data']);

      return cart;
    } else {
      throw Exception('Failed to update cart item');
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/cart/items/$itemId'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to remove from cart');
    }
  }

  static Future<void> clearCart() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/cart'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to clear cart');
    }
  }

  // Backward compatibility methods
  static Future<bool> postOrder(Order order) async {
    try {
      await createOrder(order);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Payment endpoints
  static Future<PaymentResponse> initiateMpesaPayment({
    required String orderId,
    required String phoneNumber,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/payments/mpesa/initiate'),
          headers: _headers,
          body: jsonEncode({
            'orderId': orderId,
            'phoneNumber': phoneNumber,
          }),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentResponse = PaymentResponse.fromJson(data);

      return paymentResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to initiate payment';

      throw Exception(message);
    }
  }

  static Future<PaymentData> checkPaymentStatus(String paymentId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/payments/status/$paymentId'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentData = PaymentData.fromJson(data['data']);

      return paymentData;
    } else {
      throw Exception('Failed to check payment status');
    }
  }

  static Future<List<Payment>> getPaymentHistory({
    int page = 1,
    int limit = 10,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/payments/history')
        .replace(queryParameters: queryParams);

    final response = await _makeRequest(() => http.get(uri, headers: _headers));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> payments = data['data']['payments'];
      final paymentList =
          payments.map((json) => Payment.fromJson(json)).toList();

      return paymentList;
    } else {
      throw Exception('Failed to load payment history');
    }
  }

  // Admin API endpoints
  static Future<DashboardStats> getDashboardStats() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/dashboard'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stats = DashboardStats.fromJson(data['data']);

      return stats;
    } else {
      throw Exception('Failed to fetch dashboard stats');
    }
  }

  static Future<List<Order>> getAdminOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
    };

    final uri = Uri.parse('$baseUrl/admin/orders')
        .replace(queryParameters: queryParams);

    final response = await _makeRequest(() => http.get(uri, headers: _headers));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orders = data['data']['orders'];
      final orderList = orders.map((json) => Order.fromJson(json)).toList();

      return orderList;
    } else {
      throw Exception('Failed to fetch admin orders');
    }
  }

  static Future<Order> updateOrderStatusAdmin(String id, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/admin/orders/$id/status'),
          headers: _headers,
          body: jsonEncode({'status': status}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);

      return order;
    } else {
      throw Exception('Failed to update admin order status');
    }
  }

  // Health check with detailed status
  static Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/health'),
            headers: _headers,
          ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isConnected = true;
        return {
          'connected': true,
          'status': 'healthy',
          'timestamp': DateTime.now().toIso8601String(),
          'details': data,
        };
      } else {
        _isConnected = false;
        return {
          'connected': false,
          'status': 'unhealthy',
          'timestamp': DateTime.now().toIso8601String(),
          'error': 'Backend returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      _isConnected = false;
      return {
        'connected': false,
        'status': 'error',
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  // Admin methods
  static Future<List<AdminCustomer>> getAdminCustomers() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/customers'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> customers = data['data']['customers'];
      final customerList =
          customers.map((json) => AdminCustomer.fromJson(json)).toList();

      return customerList;
    } else {
      throw Exception('Failed to fetch admin customers');
    }
  }

  static Future<List<AdminMenuItem>> getAdminMenuItems() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/menu'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data']['items'];
      final menuItems =
          items.map((json) => AdminMenuItem.fromJson(json)).toList();

      return menuItems;
    } else {
      throw Exception('Failed to fetch admin menu items');
    }
  }

  static Future<AdminMenuItem> createMenuItem(AdminMenuItem menuItem) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/admin/menu'),
          headers: _headers,
          body: jsonEncode(menuItem.toJson()),
        ));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final createdItem = AdminMenuItem.fromJson(data['data']);

      return createdItem;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to create menu item';

      throw Exception(message);
    }
  }

  static Future<AdminMenuItem> updateMenuItem(
      String id, AdminMenuItem menuItem) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.put(
          Uri.parse('$baseUrl/admin/menu/$id'),
          headers: _headers,
          body: jsonEncode(menuItem.toJson()),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final updatedItem = AdminMenuItem.fromJson(data['data']);

      return updatedItem;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to update menu item';

      throw Exception(message);
    }
  }

  static Future<void> deleteMenuItem(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/admin/menu/$id'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to delete menu item';

      throw Exception(message);
    }
  }

  static Future<List<AdminPayment>> getAdminPayments() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/payments'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> payments = data['data']['payments'];
      final paymentList =
          payments.map((json) => AdminPayment.fromJson(json)).toList();

      return paymentList;
    } else {
      throw Exception('Failed to fetch admin payments');
    }
  }

  // Utility methods
  static Future<bool> isUserVerified() async {
    if (!isAuthenticated) return false;

    try {
      final user = await getCurrentUser();
      return user.emailVerified && user.phoneVerified;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getVerificationStatus() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    try {
      final user = await getCurrentUser();
      return {
        'emailVerified': user.emailVerified,
        'phoneVerified': user.phoneVerified,
        'fullyVerified': user.emailVerified && user.phoneVerified,
      };
    } catch (e) {
      throw Exception('Failed to get verification status');
    }
  }

  // Phone verification methods
  static Future<bool> sendPhoneOtp(String phoneNumber) async {
    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/send-otp'),
          headers: _headers,
          body: jsonEncode({'phone': phoneNumber}),
        ));

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to send OTP';

      throw Exception(message);
    }
  }

  static Future<bool> verifyPhoneOtp(String phoneNumber, String otp) async {
    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/verify-otp'),
          headers: _headers,
          body: jsonEncode({
            'phone': phoneNumber,
            'otp': otp,
          }),
        ));

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to verify OTP';

      throw Exception(message);
    }
  }

  // Backward compatibility methods
  static Future<List<Order>> fetchOrders() async {
    return getOrders();
  }
}
