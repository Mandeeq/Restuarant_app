import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/menu_item_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/admin_models.dart';

class ApiService {
  // Use your computer IP address (same one used in MongoDB Compass/Postman)
  static const String baseUrl =
      "http://192.2.1.118:5000/api"; // ✅ Updated to include /api prefix

  // Store authentication token
  static String? _authToken;
  static User? _currentUser;

  // Getters
  static String? get authToken => _authToken;
  static User? get currentUser => _currentUser;
  static bool get isAuthenticated => _authToken != null;

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
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Authentication endpoints
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthData(authResponse.token, authResponse.user);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);
      setAuthData(authResponse.token, authResponse.user);
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  static Future<User> getCurrentUser() async {
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      _currentUser = user;
      return user;
    } else {
      throw Exception('Failed to get user data');
    }
  }

  // Menu endpoints
  static Future<List<MenuItem>> getMenuItems({
    String? category,
    String? dietary,
    String? search,
    String? sortBy,
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (dietary != null) queryParams['dietary'] = dietary;
    if (search != null) queryParams['search'] = search;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (page != null) queryParams['page'] = page.toString();

    final uri =
        Uri.parse('$baseUrl/menu').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((json) => MenuItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  static Future<MenuItem> getMenuItemById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/menu/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MenuItem.fromJson(data);
    } else {
      throw Exception('Failed to load menu item');
    }
  }

  // Order endpoints
  static Future<List<Order>> fetchOrders() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<Order> createOrder(Order order) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create order');
    }
  }

  static Future<Order> getOrderById(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      throw Exception('Failed to load order');
    }
  }

  static Future<Order> cancelOrder(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders/$id/cancel'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to cancel order');
    }
  }

  static Future<Order> rateOrder(
      String id, double rating, String? review) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders/$id/rate'),
      headers: _headers,
      body: jsonEncode({
        'rating': rating,
        if (review != null) 'review': review,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to rate order');
    }
  }

  // Admin endpoints
  static Future<List<Order>> getAllOrders() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all orders');
    }
  }

  static Future<List<Order>> getPendingOrders() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders/pending'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pending orders');
    }
  }

  static Future<Order> updateOrderStatus(String id, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update order status');
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Backward compatibility methods
  static Future<bool> postOrder(Order order) async {
    try {
      await createOrder(order);
      return true;
    } catch (e) {
      print('❌ Failed to post order: $e');
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

    final response = await http.post(
      Uri.parse('$baseUrl/payments/mpesa/initiate'),
      headers: _headers,
      body: jsonEncode({
        'orderId': orderId,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to initiate payment');
    }
  }

  static Future<PaymentData> checkPaymentStatus(String paymentId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/payments/status/$paymentId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentData.fromJson(data['data']);
    } else {
      throw Exception('Failed to check payment status');
    }
  }

  static Future<List<Payment>> getPaymentHistory(
      {int page = 1, int limit = 10}) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/payments/history')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> payments = data['data']['payments'];
      return payments.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment history');
    }
  }

  // Admin API endpoints
  static Future<DashboardStats> getDashboardStats() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardStats.fromJson(data['data']);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  static Future<List<AdminOrder>> getAdminOrders({
    String? status,
    String? paymentStatus,
    int page = 1,
    int limit = 20,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;

    final uri = Uri.parse('$baseUrl/admin/orders')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> orders = data['data']['orders'];
      return orders.map((json) => AdminOrder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<AdminOrder> updateAdminOrderStatus(
      String orderId, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/admin/orders/$orderId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AdminOrder.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update order status');
    }
  }

  static Future<List<AdminMenuItem>> getAdminMenuItems({
    String? category,
    bool? isAvailable,
    int page = 1,
    int limit = 20,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (category != null) queryParams['category'] = category;
    if (isAvailable != null) queryParams['available'] = isAvailable.toString();

    final uri =
        Uri.parse('$baseUrl/admin/menu').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data']['items'];
      return items.map((json) => AdminMenuItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  static Future<AdminMenuItem> createMenuItem(AdminMenuItem item) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/admin/menu'),
      headers: _headers,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AdminMenuItem.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create menu item');
    }
  }

  static Future<AdminMenuItem> updateMenuItem(
      String itemId, AdminMenuItem item) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/admin/menu/$itemId'),
      headers: _headers,
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AdminMenuItem.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update menu item');
    }
  }

  static Future<void> deleteMenuItem(String itemId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/menu/$itemId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete menu item');
    }
  }

  static Future<List<AdminCustomer>> getAdminCustomers({
    String? search,
    bool? isVerified,
    int page = 1,
    int limit = 20,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null) queryParams['search'] = search;
    if (isVerified != null) queryParams['verified'] = isVerified.toString();

    final uri = Uri.parse('$baseUrl/admin/customers')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> customers = data['data']['customers'];
      return customers.map((json) => AdminCustomer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  static Future<List<AdminPayment>> getAdminPayments({
    String? status,
    String? paymentMethod,
    int page = 1,
    int limit = 20,
  }) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;
    if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;

    final uri = Uri.parse('$baseUrl/admin/payments')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> payments = data['data']['payments'];
      return payments.map((json) => AdminPayment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }
}
