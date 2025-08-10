import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getOrders();
      print('📋 Loaded ${orders.length} orders');

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading orders: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    // Safety check for index bounds
                    if (index < 0 || index >= _orders.length) {
                      print(
                          '⚠️ Invalid index: $index, orders length: ${_orders.length}');
                      return const SizedBox.shrink();
                    }

                    final order = _orders[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                  'Order #${order.id?.substring(0, 8) ?? 'N/A'}'),
                            ),
                            Chip(
                              label: Text(order.orderStatus.toUpperCase()),
                              backgroundColor:
                                  _getStatusColor(order.orderStatus),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.user != null)
                              Text(
                                  'Customer: ${order.user!.name} (${order.user!.phone})'),
                            Text(
                                'Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                            if (order.serviceType == 'delivery' &&
                                order.deliveryAddress != null)
                              Text(
                                  'Delivery to: ${order.deliveryAddress!.street}, ${order.deliveryAddress!.city}'),
                            Text(
                                'Payment: ${order.paymentMethod} (${order.paymentStatus})'),
                          ],
                        ),
                        onTap: () => _showOrderDetails(order),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    try {
      setState(() => _isLoading = true);
      await ApiService.updateOrderStatus(order.id!, newStatus);
      await _loadOrders(); // Reload orders to get updated data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
    } catch (e) {
      print('❌ Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id?.substring(0, 8) ?? 'N/A'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer Details Section
              const Text('Customer Details:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (order.user != null) ...[
                Text('Name: ${order.user!.name}'),
                Text('Phone: ${order.user!.phone}'),
                Text('Email: ${order.user!.email}'),
              ] else
                const Text('No customer details available'),
              const SizedBox(height: 12),

              // Delivery Details Section
              if (order.serviceType == 'delivery' &&
                  order.deliveryAddress != null) ...[
                const Text('Delivery Address:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Street: ${order.deliveryAddress!.street}'),
                Text('City: ${order.deliveryAddress!.city}'),
                const SizedBox(height: 12),
              ],

              // Order Details Section
              const Text('Order Details:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
              Text('Service Type: ${order.serviceType}'),
              Text('Payment Method: ${order.paymentMethod}'),
              Text('Payment Status: ${order.paymentStatus}'),

              // Order Status Section with Dropdown
              Row(
                children: [
                  const Text('Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: order.orderStatus,
                    items: [
                      'pending',
                      'confirmed',
                      'preparing',
                      'out-for-delivery',
                      'delivered',
                      'cancelled',
                    ].map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newStatus) {
                      if (newStatus != null && newStatus != order.orderStatus) {
                        Navigator.pop(context);
                        _updateOrderStatus(order, newStatus);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Items Section
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.quantity}x ${item.name}'),
                        if (item.specialInstructions != null &&
                            item.specialInstructions!.isNotEmpty)
                          Text('  Note: ${item.specialInstructions}',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
