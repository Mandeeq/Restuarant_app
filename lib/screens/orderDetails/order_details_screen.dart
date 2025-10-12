// lib/screens/order/order_details_screen.dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import 'components/order_item_card.dart';
import 'components/price_row.dart';
import 'components/total_price.dart';
import 'order_detail_bottom_sheet.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Your Orders",
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
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
                    'No orders found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by placing your first order!',
                    style: TextStyle(
                      fontSize: 15,
                      color: bodyTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(defaultPadding),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showOrderDetailBottomSheet(context, order);
                  },
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
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
                                  const SizedBox(height: 6),
                                  Text(
                                    order.createdAt != null
                                        ? '${order.createdAt!.hour}:${order.createdAt!.minute.toString().padLeft(2, '0')}'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: bodyTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\Ksh ${order.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
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
              style: TextStyle(
                fontSize: 14,
                color: bodyTextColor,
              ),
            ),
            Text(
              'Payment: ${order.paymentMethod} (${order.paymentStatus})',
              style: TextStyle(
                fontSize: 14,
                color: bodyTextColor,
              ),
            ),
            if (order.createdAt != null)
              Text(
                'Date: ${_formatDate(order.createdAt!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: bodyTextColor,
                ),
              ),
            const Divider(color: Colors.grey, height: 24),
            ...order.items.map(
              (item) => OrderedItemCard(
                title: item.name,
                description: item.specialInstructions ?? 'No special instructions',
                numOfItem: item.quantity,
                price: item.price,
              ),
            ),
            const Divider(color: Colors.grey, height: 24),
            PriceRow(text: "Subtotal", price: order.totalAmount),
            if (order.deliveryFee > 0)
              PriceRow(text: "Delivery", price: order.deliveryFee),
            if (order.discountApplied > 0)
              PriceRow(text: "Discount", price: -order.discountApplied),
            TotalPrice(
              price: order.totalAmount + order.deliveryFee - order.discountApplied,
            ),
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
    return _formatDate(date);
  }
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