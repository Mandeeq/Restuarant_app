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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderDetailsScreen(),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders found.'),
                  SizedBox(height: 8),
                  Text('Start by placing your first order!'),
                ],
              ),
            );
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
                      child: OrderCard(order: order),
                    )),
                const SizedBox(height: defaultPadding * 2),
                PrimaryButton(
                  text: "Place New Order",
                  press: () async {
                    // Create a simple test order
                    final testOrder = Order.simple(
                      title: "Flutter Samosa",
                      price: 6.5,
                      numOfItem: 1,
                    );

                    try {
                      final createdOrder =
                          await ApiService.createOrder(testOrder);
                      if (context.mounted) {
                        final snackBar = SnackBar(
                          content:
                              Text("✅ Order placed! ID: ${createdOrder.id}"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // Refresh the page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderDetailsScreen(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final snackBar = SnackBar(
                          content: Text("❌ Failed to place order: $e"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.orderStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Service: ${order.serviceType}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Payment: ${order.paymentMethod} (${order.paymentStatus})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (order.createdAt != null)
              Text(
                'Date: ${_formatDate(order.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const Divider(),
            ...order.items.map((item) => OrderedItemCard(
                  title: item.name,
                  description:
                      item.specialInstructions ?? 'No special instructions',
                  numOfItem: item.quantity,
                  price: item.price,
                )),
            const Divider(),
            PriceRow(text: "Subtotal", price: order.totalAmount),
            if (order.deliveryFee > 0)
              PriceRow(text: "Delivery", price: order.deliveryFee),
            if (order.discountApplied > 0)
              PriceRow(text: "Discount", price: -order.discountApplied),
            TotalPrice(
                price: order.totalAmount +
                    order.deliveryFee -
                    order.discountApplied),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'out-for-delivery':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
