// lib/screens/checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../statemanagement/cart_provider.dart';
import '../../theme.dart';

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
  void dispose() {
    _allergyController.dispose();
    _mpesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    double totalAmount = cart.getTotal() + _deliveryCharge;
    int totalItems = cart.items.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    leading: Icon(
                                      Icons.fastfood,
                                      color: primaryColor,
                                    ),
                                    title: Text(
                                      cart.items[index],
                                      style: TextStyle(color: titleColor),
                                    ),
                                    trailing: Text(
                                      '\Ksh ${(cart.getItemPrice(cart.items[index]) * 150).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
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
                    _buildCard(
                      title: "Any Allergies?",
                      icon: Icons.warning_amber,
                      child: TextField(
                        controller: _allergyController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Let us know if you have any allergies (optional)...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          filled: true,
                          fillColor: inputColor,
                          prefixIcon: Icon(
                            Icons.note_alt_outlined,
                            color: bodyTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: "Need Cutlery?",
                      icon: Icons.restaurant,
                      child: SwitchListTile.adaptive(
                        title: const Text("Add Cutlery"),
                        value: _needCutlery,
                        onChanged: (value) => setState(() => _needCutlery = value),
                        secondary: Icon(Icons.flatware, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: "Delivery Option",
                      icon: Icons.local_shipping,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text("Standard Delivery (Free, may delay)"),
                            secondary: Icon(Icons.access_time, color: primaryColor),
                            value: "Standard",
                            groupValue: _selectedDelivery,
                            onChanged: (value) => setState(() {
                              _selectedDelivery = value!;
                              _deliveryCharge = 0;
                            }),
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text("Economy Delivery (\Ksh 200, faster)"),
                            secondary: const Icon(Icons.bolt, color: Colors.orange),
                            value: "Economy",
                            groupValue: _selectedDelivery,
                            onChanged: (value) => setState(() {
                              _selectedDelivery = value!;
                              _deliveryCharge = 200;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: "Choose Payment Method",
                      icon: Icons.payment,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Cash'),
                            secondary: Icon(Icons.attach_money, color: primaryColor),
                            value: 'Cash',
                            groupValue: _selectedPayment,
                            onChanged: (value) => setState(() => _selectedPayment = value!),
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text('M-Pesa'),
                            secondary: const Icon(Icons.phone_android, color: Colors.green),
                            value: 'M-Pesa',
                            groupValue: _selectedPayment,
                            onChanged: (value) => setState(() => _selectedPayment = value!),
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
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  prefixIcon: const Icon(Icons.phone_android, color: Colors.green),
                                  filled: true,
                                  fillColor: inputColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: "Order Summary",
                      icon: Icons.receipt_long,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow("Total Items", "$totalItems"),
                          _buildSummaryRow(
                            "Delivery",
                            _deliveryCharge == 0
                                ? "Free (Standard)"
                                : "\Ksh $_deliveryCharge (Economy)",
                          ),
                          _buildSummaryRow(
                            "Total Amount",
                            "\Ksh ${totalAmount.toStringAsFixed(0)}",
                            isTotal: true,
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
                  icon: const Icon(Icons.check_circle_outline, size: 22, color: Colors.white),
                  label: const Text('Place Order', style: TextStyle(color: Colors.white)),
                  onPressed: () => _showOrderConfirmation(context, totalAmount, totalItems),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: bodyTextColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? primaryColor : titleColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context, double totalAmount, int totalItems) {
    String allergyNote = _allergyController.text.isNotEmpty
        ? _allergyController.text
        : "None";
    String cutleryNote = _needCutlery ? "Yes, include cutlery" : "No cutlery";
    String paymentInfo = _selectedPayment == 'M-Pesa'
        ? 'M-Pesa Number: ${_mpesaController.text}'
        : 'Cash';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Order Placed'),
          ],
        ),
        content: Text(
          'Payment Method: $paymentInfo\n'
          'Delivery Option: $_selectedDelivery\n'
          'Products Ordered: $totalItems\n'
          'Total: \Ksh ${totalAmount.toStringAsFixed(0)}\n'
          'Allergies: $allergyNote\n'
          'Cutlery: $cutleryNote',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartProvider>().clearCart();
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}