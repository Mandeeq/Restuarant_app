import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/cart_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class AppStateService extends ChangeNotifier {
  // Authentication state
  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  bool _isConnected = false;

  // Cart state
  Cart? _cart;
  bool _isCartLoading = false;

  // Menu state
  List<MenuItem> _menuItems = [];
  bool _isMenuLoading = false;
  String? _selectedCategory;
  String? _searchQuery;

  // Order state
  List<Order> _orders = [];
  bool _isOrdersLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _authToken != null && _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Cart? get cart => _cart;
  bool get isCartLoading => _isCartLoading;
  int get cartItemCount => _cart?.itemCount ?? 0;
  bool get isCartEmpty => _cart?.isEmpty ?? true;

  List<MenuItem> get menuItems => _menuItems;
  bool get isMenuLoading => _isMenuLoading;
  String? get selectedCategory => _selectedCategory;
  String? get searchQuery => _searchQuery;

  List<Order> get orders => _orders;
  bool get isOrdersLoading => _isOrdersLoading;

  // Connection management
  Future<bool> checkConnection() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isConnected = await ApiService.testConnection();
      if (_isConnected) {
        print('✅ App connected to backend');
      } else {
        print('❌ App disconnected from backend');
      }
    } catch (e) {
      _isConnected = false;
      print('❌ Connection check failed: $e');
    }

    _isLoading = false;
    notifyListeners();
    return _isConnected;
  }

  // Authentication methods
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email: email, password: password);
      _currentUser = response.user;
      _authToken = response.token;

      // Load user data after successful login
      await _loadUserData();

      print('✅ Login successful: ${_currentUser?.name}');
      return true;
    } catch (e) {
      print('❌ Login failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _currentUser = response.user;
      _authToken = response.token;

      // Load user data after successful registration
      await _loadUserData();

      print('✅ Registration successful: ${_currentUser?.name}');
      return true;
    } catch (e) {
      print('❌ Registration failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
    _cart = null;
    _menuItems.clear();
    _orders.clear();
    ApiService.clearAuthData();
    print('🔓 Logout successful');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    if (_authToken != null) {
      try {
        final user = await ApiService.getCurrentUser();
        _currentUser = user;
        await _loadUserData();
        print('✅ Auth status verified');
      } catch (e) {
        print('❌ Auth status check failed: $e');
        logout();
      }
    }
  }

  // Cart methods
  Future<void> loadCart() async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      _cart = await ApiService.getCart();
      print('✅ Cart loaded with ${_cart?.items.length ?? 0} items');
    } catch (e) {
      print('❌ Failed to load cart: $e');
      _cart = null;
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String menuItemId, int quantity) async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      _cart = await ApiService.addToCart(menuItemId, quantity);
      print('✅ Item added to cart');
    } catch (e) {
      print('❌ Failed to add to cart: $e');
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String itemId, int quantity) async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      _cart = await ApiService.updateCartItem(itemId, quantity);
      print('✅ Cart item updated');
    } catch (e) {
      print('❌ Failed to update cart item: $e');
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      await ApiService.removeFromCart(itemId);
      await loadCart(); // Reload cart to get updated state
      print('✅ Item removed from cart');
    } catch (e) {
      print('❌ Failed to remove from cart: $e');
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (!isAuthenticated) return;

    _isCartLoading = true;
    notifyListeners();

    try {
      await ApiService.clearCart();
      _cart = null;
      print('✅ Cart cleared');
    } catch (e) {
      print('❌ Failed to clear cart: $e');
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  // Menu methods
  Future<void> loadMenuItems({
    String? category,
    String? search,
    bool refresh = false,
  }) async {
    if (!refresh &&
        _menuItems.isNotEmpty &&
        category == _selectedCategory &&
        search == _searchQuery) {
      return; // Already loaded with same filters
    }

    _isMenuLoading = true;
    _selectedCategory = category;
    _searchQuery = search;
    notifyListeners();

    try {
      _menuItems = await ApiService.getMenuItems(
        category: category,
        search: search,
      );
      print('✅ Menu items loaded: ${_menuItems.length} items');
    } catch (e) {
      print('❌ Failed to load menu items: $e');
      _menuItems = [];
    } finally {
      _isMenuLoading = false;
      notifyListeners();
    }
  }

  // Order methods
  Future<void> loadOrders({bool refresh = false}) async {
    if (!isAuthenticated) return;

    _isOrdersLoading = true;
    notifyListeners();

    try {
      _orders = await ApiService.getOrders();
      print('✅ Orders loaded: ${_orders.length} orders');
    } catch (e) {
      print('❌ Failed to load orders: $e');
      _orders = [];
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> createOrder(Order order) async {
    if (!isAuthenticated) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final createdOrder = await ApiService.createOrder(order);

      // Clear cart after successful order creation
      await clearCart();

      // Reload orders
      await loadOrders(refresh: true);

      print('✅ Order created: ${createdOrder.id}');
      return createdOrder;
    } catch (e) {
      print('❌ Failed to create order: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  Future<void> _loadUserData() async {
    if (!isAuthenticated) return;

    // Load cart and orders in parallel
    await Future.wait([
      loadCart(),
      loadOrders(),
    ]);
  }

  // Initialize app state
  Future<void> initialize() async {
    print('🚀 Initializing app state...');

    // Check connection first
    await checkConnection();

    // Check authentication status
    await checkAuthStatus();

    print('✅ App state initialized');
  }

  // Refresh all data
  Future<void> refreshAll() async {
    if (!isAuthenticated) return;

    await Future.wait([
      loadCart(),
      loadMenuItems(refresh: true),
      loadOrders(refresh: true),
    ]);
  }
}
