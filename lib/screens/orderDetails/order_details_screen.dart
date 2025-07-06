import 'package:flutter/material.dart';
import '../../components/buttons/primary_button.dart';
import '../../constants.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import 'components/order_item_card.dart';
import 'components/price_row.dart';
import 'components/total_price.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Orders")),
      body: FutureBuilder<List<Order>>(
        future: ApiService.fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: defaultPadding),
                ...orders.map((order) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding / 2),
                      child: OrderedItemCard(
                        title: order.title,
                        description: "Fetched from API",
                        numOfItem: order.numOfItem,
                        price: order.price,
                      ),
                    )),
                const PriceRow(text: "Subtotal", price: 28.0),
                const SizedBox(height: defaultPadding / 2),
                const PriceRow(text: "Delivery", price: 0),
                const SizedBox(height: defaultPadding / 2),
                const TotalPrice(price: 28.0),
                const SizedBox(height: defaultPadding * 2),
               PrimaryButton(
  text: "Checkout",
  press: () async {
    final order = Order(title: "Flutter Samosa", price: 6.5, numOfItem: 1);

    final success = await ApiService.postOrder(order);

    if (context.mounted) {
      final snackBar = SnackBar(
        content: Text(success ? "✅ Order placed!" : "❌ Failed to place order"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  },
),

              ],
            ),
          );
        },
      ),
    );
  }
}
