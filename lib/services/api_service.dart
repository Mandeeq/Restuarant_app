import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/menu_item_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../models/admin_models.dart';
import '../models/cart_model.dart';
import '../models/auth_response.dart';

class ApiService {
  // Use your computer IP address (same one used in MongoDB Compass/Postman)
  static const String baseUrl = "http://192.12.1.105:5000/api";

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
    print('✅ Authentication data set for user: ${user.name}');
  }

  // Clear authentication data
  static void clearAuthData() {
    _authToken = null;
    _currentUser = null;
    print('🔓 Authentication data cleared');
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
      print('🔍 Testing connection to backend...');
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(connectionTimeout);

      _isConnected = response.statusCode == 200;
      print(_isConnected
          ? '✅ Backend connection successful'
          : '❌ Backend connection failed');
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      print('❌ Backend connection error: $e');
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
        print('⚠️ Request attempt $attempts failed: $e');
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
    print('📝 Registering user: $email');

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
      print('✅ Registration successful for: ${authResponse.user.name}');
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Registration failed';
      print('❌ Registration failed: $message');
      throw Exception(message);
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    print('🔐 Logging in user: $email');

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
      print('✅ Login successful for: ${authResponse.user.name}');
      return authResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Login failed';
      print('❌ Login failed: $message');
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
      print('✅ Current user retrieved: ${user.name}');
      return user;
    } else {
      print('❌ Failed to get current user');
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
    print('🍽️ Fetching menu items...');

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
        print('📊 Menu API Response: $data'); // Debug log
        print('📊 Response keys: ${data.keys.toList()}'); // Debug log

        // Handle different response structures
        List<dynamic> items = [];
        if (data['items'] != null) {
          items = data['items'];
        } else if (data['data'] != null && data['data']['items'] != null) {
          items = data['data']['items'];
        } else if (data['data'] != null && data['data'] is List) {
          items = data['data'];
    } else {
          print('⚠️ Unexpected menu response structure: $data');
          return []; // Return empty list instead of throwing
        }

        print('📊 Items array length: ${items.length}'); // Debug log

        if (items.isEmpty) {
          print('⚠️ No menu items found');
          return [];
        }

        final menuItems = items
            .map((json) {
              try {
                final item = MenuItem.fromJson(json);
                print('✅ Parsed menu item: ${item.name} with image: ${item.imageUrl}');
                return item;
              } catch (e) {
                print('❌ Error parsing menu item: $e');
                print('❌ JSON data: $json');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<MenuItem>()
            .toList();

        print('✅ Retrieved ${menuItems.length} menu items');
        return menuItems;
    } else {
        print('❌ Failed to fetch menu items: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('Failed to fetch menu items');
      }
    } catch (e) {
      print('❌ Error in getMenuItems: $e');
      return [];
    }
  }

  static Future<MenuItem> getMenuItem(String id) async {
    print('🍽️ Fetching menu item: $id');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/menu/$id'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final menuItem = MenuItem.fromJson(data['data']);
      print('✅ Retrieved menu item: ${menuItem.name}');
      return menuItem;
    } else {
      print('❌ Failed to fetch menu item: $id');
      throw Exception('Failed to fetch menu item');
    }
  }

  // Order endpoints
  static Future<Order> createOrder(Order order) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('📦 Creating order...');

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/orders'),
      headers: _headers,
          body: jsonEncode(order.toJson()),
        ));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final createdOrder = Order.fromJson(data['data']['order']);
      print('✅ Order created successfully: ${createdOrder.id}');
      return createdOrder;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to create order';
      print('❌ Order creation failed: $message');
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

    print('📋 Fetching orders...');

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
      print('📊 Orders API Response: $data'); // Debug log
      print('📊 Response type: ${data.runtimeType}'); // Debug log

      List<dynamic> orders = [];
      if (data is List) {
        // Backend returns orders directly as array
        orders = data;
        print('📊 Parsing as direct array with ${orders.length} items');
      } else if (data['data'] != null && data['data'] is List) {
        // Backend returns orders in data field as array
        orders = data['data'];
        print('📊 Parsing as data array with ${orders.length} items');
      } else if (data['data'] != null && data['data']['orders'] != null) {
        // Backend returns orders in data.orders field
        orders = data['data']['orders'];
        print('📊 Parsing as data.orders array with ${orders.length} items');
      } else {
        print('⚠️ Unexpected orders response structure: $data');
        return [];
      }

      print('📊 Processing ${orders.length} orders...');
      final orderList = <Order>[];

      for (int i = 0; i < orders.length; i++) {
        try {
          final orderJson = orders[i];
          print('📊 Processing order $i: $orderJson');
          final order = Order.fromJson(orderJson);
          orderList.add(order);
        } catch (e) {
          print('❌ Error processing order $i: $e');
          print('❌ Order data: ${orders[i]}');
        }
      }

      print('✅ Retrieved ${orderList.length} orders');
      return orderList;
    } else {
      print('❌ Failed to fetch orders: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      throw Exception('Failed to fetch orders');
    }
  }

  static Future<Order> getOrder(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('📦 Fetching order: $id');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/orders/$id'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);
      print('✅ Retrieved order: ${order.id}');
      return order;
    } else {
      print('❌ Failed to fetch order: $id');
      throw Exception('Failed to fetch order');
    }
  }

  static Future<Order> updateOrderStatus(String id, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🔄 Updating order status: $id to $status');

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/orders/$id/status'),
      headers: _headers,
          body: jsonEncode({'status': status}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);
      print('✅ Order status updated: ${order.id} to ${order.orderStatus}');
      return order;
    } else {
      print('❌ Failed to update order status: $id');
      throw Exception('Failed to update order status');
    }
  }

  // Cart endpoints
  static Future<Cart> getCart() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🛒 Fetching cart...');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/cart'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = Cart.fromJson(data['data']);
      print('✅ Cart retrieved with ${cart.items.length} items');
      return cart;
    } else {
      print('❌ Failed to fetch cart');
      throw Exception('Failed to fetch cart');
    }
  }

  static Future<Cart> addToCart(String menuItemId, int quantity) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('➕ Adding to cart: $menuItemId x $quantity');

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
      print('✅ Item added to cart');
      return cart;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to add to cart';
      print('❌ Failed to add to cart: $message');
      throw Exception(message);
    }
  }

  static Future<Cart> updateCartItem(String itemId, int quantity) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('✏️ Updating cart item: $itemId to quantity $quantity');

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/cart/items/$itemId'),
      headers: _headers,
          body: jsonEncode({'quantity': quantity}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cart = Cart.fromJson(data['data']);
      print('✅ Cart item updated');
      return cart;
    } else {
      print('❌ Failed to update cart item');
      throw Exception('Failed to update cart item');
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🗑️ Removing from cart: $itemId');

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/cart/items/$itemId'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      print('✅ Item removed from cart');
    } else {
      print('❌ Failed to remove from cart');
      throw Exception('Failed to remove from cart');
    }
  }

  static Future<void> clearCart() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🧹 Clearing cart...');

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/cart'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      print('✅ Cart cleared');
    } else {
      print('❌ Failed to clear cart');
      throw Exception('Failed to clear cart');
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

    print('💳 Initiating M-Pesa payment for order: $orderId');

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
      print('✅ M-Pesa payment initiated successfully');
      return paymentResponse;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to initiate payment';
      print('❌ M-Pesa payment initiation failed: $message');
      throw Exception(message);
    }
  }

  static Future<PaymentData> checkPaymentStatus(String paymentId) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🔍 Checking payment status: $paymentId');

    final response = await _makeRequest(() => http.get(
      Uri.parse('$baseUrl/payments/status/$paymentId'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final paymentData = PaymentData.fromJson(data['data']);
      print('✅ Payment status checked');
      return paymentData;
    } else {
      print('❌ Failed to check payment status');
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

    print('📊 Fetching payment history...');

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
      print('✅ Retrieved ${paymentList.length} payment records');
      return paymentList;
    } else {
      print('❌ Failed to load payment history');
      throw Exception('Failed to load payment history');
    }
  }

  // Admin API endpoints
  static Future<DashboardStats> getDashboardStats() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('📈 Fetching dashboard stats...');

    final response = await _makeRequest(() => http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stats = DashboardStats.fromJson(data['data']);
      print('✅ Dashboard stats retrieved');
      return stats;
    } else {
      print('❌ Failed to fetch dashboard stats');
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

    print('📋 Fetching admin orders...');

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
      print('✅ Retrieved ${orderList.length} admin orders');
      return orderList;
    } else {
      print('❌ Failed to fetch admin orders');
      throw Exception('Failed to fetch admin orders');
    }
  }

  static Future<Order> updateOrderStatusAdmin(String id, String status) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🔄 Admin updating order status: $id to $status');

    final response = await _makeRequest(() => http.patch(
          Uri.parse('$baseUrl/admin/orders/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);
      print(
          '✅ Admin order status updated: ${order.id} to ${order.orderStatus}');
      return order;
    } else {
      print('❌ Failed to update admin order status: $id');
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

    print('👥 Fetching admin customers...');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/customers'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> customers = data['data']['customers'];
      final customerList =
          customers.map((json) => AdminCustomer.fromJson(json)).toList();
      print('✅ Retrieved ${customerList.length} customers');
      return customerList;
    } else {
      print('❌ Failed to fetch admin customers');
      throw Exception('Failed to fetch admin customers');
    }
  }

  static Future<List<AdminMenuItem>> getAdminMenuItems() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🍽️ Fetching admin menu items...');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/menu'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data']['items'];
      final menuItems =
          items.map((json) => AdminMenuItem.fromJson(json)).toList();
      print('✅ Retrieved ${menuItems.length} admin menu items');
      return menuItems;
    } else {
      print('❌ Failed to fetch admin menu items');
      throw Exception('Failed to fetch admin menu items');
    }
  }

  static Future<AdminMenuItem> createMenuItem(AdminMenuItem menuItem) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('➕ Creating menu item: ${menuItem.name}');

    final response = await _makeRequest(() => http.post(
      Uri.parse('$baseUrl/admin/menu'),
      headers: _headers,
          body: jsonEncode(menuItem.toJson()),
        ));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final createdItem = AdminMenuItem.fromJson(data['data']);
      print('✅ Menu item created: ${createdItem.name}');
      return createdItem;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to create menu item';
      print('❌ Failed to create menu item: $message');
      throw Exception(message);
    }
  }

  static Future<AdminMenuItem> updateMenuItem(
      String id, AdminMenuItem menuItem) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('✏️ Updating menu item: $id');

    final response = await _makeRequest(() => http.put(
          Uri.parse('$baseUrl/admin/menu/$id'),
      headers: _headers,
          body: jsonEncode(menuItem.toJson()),
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final updatedItem = AdminMenuItem.fromJson(data['data']);
      print('✅ Menu item updated: ${updatedItem.name}');
      return updatedItem;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to update menu item';
      print('❌ Failed to update menu item: $message');
      throw Exception(message);
    }
  }

  static Future<void> deleteMenuItem(String id) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('🗑️ Deleting menu item: $id');

    final response = await _makeRequest(() => http.delete(
          Uri.parse('$baseUrl/admin/menu/$id'),
      headers: _headers,
        ));

    if (response.statusCode == 200) {
      print('✅ Menu item deleted: $id');
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to delete menu item';
      print('❌ Failed to delete menu item: $message');
      throw Exception(message);
    }
  }

  static Future<List<AdminPayment>> getAdminPayments() async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }

    print('💰 Fetching admin payments...');

    final response = await _makeRequest(() => http.get(
          Uri.parse('$baseUrl/admin/payments'),
          headers: _headers,
        ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> payments = data['data']['payments'];
      final paymentList =
          payments.map((json) => AdminPayment.fromJson(json)).toList();
      print('✅ Retrieved ${paymentList.length} admin payments');
      return paymentList;
    } else {
      print('❌ Failed to fetch admin payments');
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
    print('📱 Sending OTP to: $phoneNumber');

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/send-otp'),
          headers: _headers,
          body: jsonEncode({'phone': phoneNumber}),
        ));

    if (response.statusCode == 200) {
      print('✅ OTP sent successfully');
      return true;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to send OTP';
      print('❌ Failed to send OTP: $message');
      throw Exception(message);
    }
  }

  static Future<bool> verifyPhoneOtp(String phoneNumber, String otp) async {
    print('🔐 Verifying OTP for: $phoneNumber');

    final response = await _makeRequest(() => http.post(
          Uri.parse('$baseUrl/auth/verify-otp'),
          headers: _headers,
          body: jsonEncode({
            'phone': phoneNumber,
            'otp': otp,
          }),
        ));

    if (response.statusCode == 200) {
      print('✅ Phone verification successful');
      return true;
    } else {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Failed to verify OTP';
      print('❌ Failed to verify OTP: $message');
      throw Exception(message);
    }
  }

  // Backward compatibility methods
  static Future<List<Order>> fetchOrders() async {
    return getOrders();
  }
}
