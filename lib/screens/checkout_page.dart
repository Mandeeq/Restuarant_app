import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final List<String> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Cash';

  int get totalAmount => widget.cartItems.length * 150; // example: each item = 150

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items in your cart:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(widget.cartItems[index]),
                  trailing: const Text('KSh 150'), // sample price
                ),
              ),
            ),
            const Divider(),
            Text('Total: KSh $totalAmount', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Choose payment method:', style: TextStyle(fontSize: 16)),
            ListTile(
              title: const Text('Cash'),
              leading: Radio(
                value: 'Cash',
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('M-Pesa'),
              leading: Radio(
                value: 'M-Pesa',
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Replace this with real payment submission logic
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Order Placed'),
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
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
