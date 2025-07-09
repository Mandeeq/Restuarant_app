import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _currentUser != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      final response = await ApiService.login(email: email, password: password);
      _currentUser = response.user;
      _token = response.token;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    setLoading(true);
    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _currentUser = response.user;
      _token = response.token;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    _token = null;
    ApiService.clearAuthData();
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    if (_token != null) {
      try {
        final user = await ApiService.getCurrentUser();
        _currentUser = user;
        notifyListeners();
      } catch (e) {
        // Token might be expired
        logout();
      }
    }
  }
}
