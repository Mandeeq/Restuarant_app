import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<String> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Cash';
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _paymentInitiated = false;
  String? _paymentId;
  Timer? _statusCheckTimer;

  int get totalAmount => widget.cartItems.length * 150;

  Future<void> _placeOrder() async {
    if (_selectedPayment == 'M-Pesa') {
      if (_phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid phone number'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _initiateMpesaPayment();
    } else {
      _showOrderSuccessDialog();
    }
  }

  Future<void> _initiateMpesaPayment() async {
    setState(() => _isLoading = true);

    try {
      // Create order first
      final order = await ApiService.createOrder(Order(
        items: widget.cartItems
            .map((item) => OrderItem(
                  menuItemId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  name: item,
                  price: 150.0,
                  quantity: 1,
                ))
            .toList(),
        totalAmount: totalAmount.toDouble(),
        serviceType: 'delivery',
        paymentMethod: 'mpesa',
      ));

      // Initiate M-Pesa payment
      final response = await ApiService.initiateMpesaPayment(
        orderId: order.id!,
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _paymentInitiated = true;
          _paymentId = response.data?.paymentId;
        });

        // Start checking payment status
        _startPaymentStatusCheck();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startPaymentStatusCheck() {
    if (_paymentId == null) return;

    _statusCheckTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final paymentData = await ApiService.checkPaymentStatus(_paymentId!);

        if (mounted) {
          if (paymentData.status == 'completed') {
            timer.cancel();
            _showPaymentSuccessDialog();
          } else if (paymentData.status == 'failed') {
            timer.cancel();
            _showPaymentFailedDialog();
          }
        }
      } catch (e) {
        // Continue checking
      }
    });
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: const Text(
            'Your M-Pesa payment has been processed successfully. You will receive a confirmation shortly.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: const Text(
            'Your M-Pesa payment was not successful. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initiateMpesaPayment();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✅ Order Placed'),
        content:
            Text('Payment Method: $_selectedPayment\nTotal: KSh $totalAmount'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (ApiService.currentUser?.phone != null) {
      _phoneController.text = ApiService.currentUser!.phone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🛒 Items in Your Cart',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(widget.cartItems[index]),
                        trailing: const Text('KSh 150'),
                      ),
                    ),
                    const Divider(height: 30, thickness: 1),
                    Text(
                      '🧾 Total: KSh $totalAmount',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      '💳 Choose Payment Method',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash'),
                      value: 'Cash',
                      groupValue: _selectedPayment,
                      onChanged: (value) =>
                          setState(() => _selectedPayment = value!),
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.phone_android,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          const Text('M-Pesa'),
                        ],
                      ),
                      value: 'M-Pesa',
                      groupValue: _selectedPayment,
                      onChanged: (value) =>
                          setState(() => _selectedPayment = value!),
                    ),
                    if (_selectedPayment == 'M-Pesa') ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone_android,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  const Text('M-Pesa Payment',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Enter M-Pesa phone number (e.g., 0712345678)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                  suffixIcon: Icon(Icons.phone_android,
                                      color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_selectedPayment == 'M-Pesa') ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  const Text('M-Pesa Payment Instructions',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Ensure your phone number is registered with M-Pesa\n'
                                '• You will receive an STK push notification\n'
                                '• Enter your M-Pesa PIN when prompted\n'
                                '• Payment will be processed automatically\n'
                                '• You will receive an SMS confirmation',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_paymentInitiated) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Checking M-Pesa payment status...',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 10, 16, 30), // lifted the button
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF6D4C41),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Text(_selectedPayment == 'M-Pesa'
                          ? 'Pay with M-Pesa'
                          : 'Place Order'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
