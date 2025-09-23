import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/statemanagement/cart_provider.dart'; // adjust the path if needed

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Cash';
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _mpesaController = TextEditingController();
  bool _needCutlery = false;

  String _selectedDelivery = 'Standard';
  int _deliveryCharge = 0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    double totalAmount = cart.getTotal() + _deliveryCharge;
    int totalItems = cart.items.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F4),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF6D4C41),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items Section
                    _buildCard(
                      title: "Items in Your Cart",
                      icon: Icons.shopping_cart,
                      child: cart.items.isEmpty
                          ? const Text("Your cart is empty")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) => Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.fastfood,
                                        color: Colors.black),
                                    title: Text(cart.items[index]),
                                    trailing: Text(
                                      'KSh ${(cart.getItemPrice(cart.items[index]) * 150).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (index != cart.items.length - 1)
                                    const Divider(),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Allergies Section
                    _buildCard(
                      title: "Any Allergies?",
                      icon: Icons.warning_amber,
                      child: TextField(
                        controller: _allergyController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              "Let us know if you have any allergies (optional)...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(Icons.note_alt_outlined,
                              color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cutlery Section
                    _buildCard(
                      title: "Need Cutlery?",
                      icon: Icons.restaurant,
                      child: SwitchListTile(
                        title: const Text("Add Cutlery"),
                        value: _needCutlery,
                        onChanged: (value) {
                          setState(() {
                            _needCutlery = value;
                          });
                        },
                        secondary:
                            const Icon(Icons.flatware, color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Delivery Options
                    _buildCard(
                      title: "Delivery Option",
                      icon: Icons.local_shipping,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text(
                                "Standard Delivery (Free, may delay)"),
                            secondary: const Icon(Icons.access_time,
                                color: Colors.black),
                            value: "Standard",
                            groupValue: _selectedDelivery,
                            onChanged: (value) {
                              setState(() {
                                _selectedDelivery = value!;
                                _deliveryCharge = 0;
                              });
                            },
                          ),
                          const Divider(height: 0),
                          RadioListTile<String>(
                            title: const Text(
                                "Economy Delivery (KSh 200, faster)"),
                            secondary:
                                const Icon(Icons.bolt, color: Colors.black),
                            value: "Economy",
                            groupValue: _selectedDelivery,
                            onChanged: (value) {
                              setState(() {
                                _selectedDelivery = value!;
                                _deliveryCharge = 200;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Options
                    _buildCard(
                      title: "Choose Payment Method",
                      icon: Icons.payment,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Cash'),
                            secondary: const Icon(Icons.attach_money,
                                color: Colors.black),
                            value: 'Cash',
                            groupValue: _selectedPayment,
                            onChanged: (value) {
                              setState(() {
                                _selectedPayment = value!;
                              });
                            },
                          ),
                          const Divider(height: 0),
                          RadioListTile<String>(
                            title: const Text('M-Pesa'),
                            secondary: const Icon(Icons.phone_android,
                                color: Colors.black),
                            value: 'M-Pesa',
                            groupValue: _selectedPayment,
                            onChanged: (value) {
                              setState(() {
                                _selectedPayment = value!;
                              });
                            },
                          ),
                          if (_selectedPayment == 'M-Pesa')
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextField(
                                controller: _mpesaController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Enter M-Pesa number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.phone_android,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Order Summary
                    _buildCard(
                      title: "Order Summary",
                      icon: Icons.receipt_long,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Items"),
                              Text(
                                "$totalItems",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Delivery"),
                              Text(
                                _deliveryCharge == 0
                                    ? "Free (Standard)"
                                    : "KSh $_deliveryCharge (Economy)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Amount"),
                              Text(
                                "KSh ${totalAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D4C41),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Place Order Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline,
                      size: 22, color: Colors.white),
                  label: const Text('Place Order'),
                  onPressed: () {
                    String allergyNote = _allergyController.text.isNotEmpty
                        ? _allergyController.text
                        : "None";

                    String cutleryNote =
                        _needCutlery ? "Yes, include cutlery" : "No cutlery";

                    String paymentInfo = _selectedPayment == 'M-Pesa'
                        ? 'M-Pesa Number: ${_mpesaController.text}'
                        : 'Cash';

                    // Show confirmation
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Order Placed'),
                          ],
                        ),
                        content: Text(
                          'Payment Method: $paymentInfo\n'
                          'Delivery Option: $_selectedDelivery\n'
                          'Products Ordered: $totalItems\n'
                          'Total: KSh ${totalAmount.toStringAsFixed(0)}\n'
                          'Allergies: $allergyNote\n'
                          'Cutlery: $cutleryNote',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // clear the cart using provider
                              context.read<CartProvider>().clearCart();
                              Navigator.pop(context, true);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4C41),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Card Widget
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
