// lib/screens/cart/cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../statemanagement/cart_provider.dart';
import '../../theme.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, required List cartItems});

  double calculateTotal(Map<String, double> itemPrices, List<String> items) {
    return items.fold(0.0, (sum, item) => sum + (itemPrices[item] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final Map<String, double> itemPrices = {
      'Espresso': 3.50,
      'Cappuccino': 4.00,
      'Latte': 4.25,
      'Mocha': 4.50,
      'Americano': 3.75,
      'Flat White': 4.00,
      'Macchiato': 3.80,
      'Cold Brew': 4.25,
    };

    final double total = calculateTotal(itemPrices, cart.items);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? _buildEmptyCart(context)
                : _buildCartList(context, cart, itemPrices),
          ),
          if (cart.items.isNotEmpty) _buildCheckoutPanel(context, total),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite items to get started!',
            style: TextStyle(
              fontSize: 15,
              color: bodyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
      BuildContext context, CartProvider cart, Map<String, double> prices) {
    return ListView.builder(
      padding: const EdgeInsets.all(defaultPadding),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final price = prices[item] ?? 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.fastfood,
                color: primaryColor,
                size: 28,
              ),
            ),
            title: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: titleColor,
              ),
            ),
            subtitle: Text(
              '\Ksh ${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                final removed = item;
                cart.removeItem(index);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$removed removed from cart'),
                    backgroundColor: primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutPanel(BuildContext context, double total) {
    final cart = context.watch<CartProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
          top: 12,
          bottom: 24,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${cart.items.length} items)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: bodyTextColor,
                    ),
                  ),
                  Text(
                    '\Ksh ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}