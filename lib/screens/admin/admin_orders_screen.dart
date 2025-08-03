import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<AdminOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getAdminOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
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
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${order.customerName}'),
                            Text(
                                'Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                            Text('Status: ${order.status}'),
                            Text('Payment: ${order.paymentStatus}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(order.status.toUpperCase()),
                          backgroundColor: _getStatusColor(order.status),
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

  void _showOrderDetails(AdminOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${order.customerName}'),
              Text('Email: ${order.customerEmail}'),
              Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
              Text('Status: ${order.status}'),
              Text('Payment: ${order.paymentStatus}'),
              const SizedBox(height: 12),
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items
                  .map((item) => Text('${item.quantity}x ${item.name}')),
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
