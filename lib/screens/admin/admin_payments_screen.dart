import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/admin_models.dart';
import '../../services/api_service.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<AdminPayment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final payments = await ApiService.getAdminPayments();
      setState(() {
        _payments = payments;
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
        title: const Text('Payment History'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? const Center(child: Text('No payments found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getPaymentStatusColor(payment.status),
                          child: Icon(
                            _getPaymentMethodIcon(payment.paymentMethod),
                            color: Colors.white,
                          ),
                        ),
                        title:
                            Text('Order #${payment.orderId.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${payment.customerName}'),
                            Text(
                                'Amount: \$${payment.amount.toStringAsFixed(2)}'),
                            Text('Method: ${payment.paymentMethod}'),
                            Text('Status: ${payment.status}'),
                            Text('Date: ${_formatDate(payment.createdAt)}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(payment.status.toUpperCase()),
                          backgroundColor:
                              _getPaymentStatusColor(payment.status),
                        ),
                        onTap: () => _showPaymentDetails(payment),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mpesa':
        return Icons.phone_android;
      case 'card':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _showPaymentDetails(AdminPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment #${payment.id.substring(0, 8)}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order ID: ${payment.orderId}'),
            Text('Customer: ${payment.customerName}'),
            Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
            Text('Method: ${payment.paymentMethod}'),
            Text('Status: ${payment.status}'),
            Text('Created: ${_formatDate(payment.createdAt)}'),
            if (payment.completedAt != null)
              Text('Completed: ${_formatDate(payment.completedAt!)}'),
            if (payment.transactionId != null)
              Text('Transaction ID: ${payment.transactionId}'),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
