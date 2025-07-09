import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class ApiService {
  // Use your computer IP address (same one used in MongoDB Compass/Postman)
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  static Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<bool> postOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('❌ Failed to post order: ${response.body}');
      return false;
    }
  }
}
