// lib/screens/orderDetails/order_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/order_model.dart';
import 'components/order_item_card.dart';
import 'components/price_row.dart';
import 'components/total_price.dart';

Map<String, OrderItem> _groupOrderItems(List<OrderItem> items) {
  final Map<String, OrderItem> groupedItems = {};
  for (final item in items) {
    if (groupedItems.containsKey(item.menuItemId)) {
      final existingItem = groupedItems[item.menuItemId]!;
      final updatedItem = OrderItem(
        menuItemId: existingItem.menuItemId,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + item.quantity,
        specialInstructions: existingItem.specialInstructions,
      );
      groupedItems[item.menuItemId] = updatedItem;
    } else {
      groupedItems[item.menuItemId] = item;
    }
  }
  return groupedItems;
}

Future<void> showOrderDetailBottomSheet(BuildContext context, Order order) {
  final groupedItems = _groupOrderItems(order.items);

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
                        'Order ${order.id?.substring(0, 8) ?? 'N/A'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Service: ${order.serviceType}', style: TextStyle(color: bodyTextColor)),
                  Text('Payment: ${order.paymentMethod} (${order.paymentStatus})', style: TextStyle(color: bodyTextColor)),
                  //const Divider(height: 2),
                  ...groupedItems.values.map((item) => OrderedItemCard(
                        title: item.name,
                        description: item.specialInstructions ?? 'No special instructions',
                        numOfItem: item.quantity,
                        price: item.price,
                      )),
                  //const Divider(height: 5),
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
