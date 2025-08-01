import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final List<String> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Cash';

  int get totalAmount => widget.cartItems.length * 150;

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🛒 Items in Your Cart',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      '💳 Choose Payment Method',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash'),
                      value: 'Cash',
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('M-Pesa'),
                      value: 'M-Pesa',
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value!),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30), // lifted the button
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('✅ Order Placed'),
                        content: Text('Payment Method: $_selectedPayment\nTotal: KSh $totalAmount'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  backgroundColor: const Color(0xFF6D4C41),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Place Order'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
