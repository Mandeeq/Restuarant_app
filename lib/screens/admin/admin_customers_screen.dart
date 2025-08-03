import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  List<AdminCustomer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await ApiService.getAdminCustomers();
      setState(() {
        _customers = customers;
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
        title: const Text('Manage Customers'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('No customers found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(customer.name[0].toUpperCase()),
                        ),
                        title: Text(customer.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${customer.email}'),
                            if (customer.phone != null)
                              Text('Phone: ${customer.phone}'),
                            Text('Orders: ${customer.totalOrders}'),
                            Text(
                                'Total Spent: \$${customer.totalSpent.toStringAsFixed(2)}'),
                            Text(
                                'Verified: ${customer.isVerified ? "Yes" : "No"}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _showCustomerDetails(customer),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCustomerDetails(AdminCustomer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${customer.email}'),
            if (customer.phone != null) Text('Phone: ${customer.phone}'),
            Text('Total Orders: ${customer.totalOrders}'),
            Text('Total Spent: \$${customer.totalSpent.toStringAsFixed(2)}'),
            Text('Verified: ${customer.isVerified ? "Yes" : "No"}'),
            Text('Joined: ${_formatDate(customer.createdAt)}'),
            if (customer.lastOrderDate != null)
              Text('Last Order: ${_formatDate(customer.lastOrderDate!)}'),
          ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
