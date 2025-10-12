// lib/screens/orderDetails/order_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/order_model.dart';
import 'components/order_item_card.dart';
import 'components/price_row.dart';
import 'components/total_price.dart';

Future<void> showOrderDetailBottomSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Service: ${order.serviceType}', style: TextStyle(color: bodyTextColor)),
                  Text('Payment: ${order.paymentMethod} (${order.paymentStatus})', style: TextStyle(color: bodyTextColor)),
                  const Divider(height: 20),
                  ...order.items.map((item) => OrderedItemCard(
                        title: item.name,
                        description: item.specialInstructions ?? 'No special instructions',
                        numOfItem: item.quantity,
                        price: item.price,
                      )),
                  const Divider(height: 20),
                  PriceRow(text: 'Subtotal', price: order.totalAmount),
                  if (order.deliveryFee > 0) PriceRow(text: 'Delivery', price: order.deliveryFee),
                  if (order.discountApplied > 0) PriceRow(text: 'Discount', price: -order.discountApplied),
                  TotalPrice(price: order.totalAmount + order.deliveryFee - order.discountApplied),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
