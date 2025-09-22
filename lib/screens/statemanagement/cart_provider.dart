import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<String> _items = [];

  final Map<String, double> _itemPrices = {
    'Espresso': 3.50,
    'Cappuccino': 4.00,
    'Latte': 4.25,
    'Mocha': 4.50,
    'Americano': 3.75,
    'Flat White': 4.00,
    'Macchiato': 3.80,
    'Cold Brew': 4.25,
  };

  List<String> get items => List.unmodifiable(_items);

  void addItem(String item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double getTotal() {
    return _items.fold(0, (sum, item) => sum + (_itemPrices[item] ?? 0));
  }

  double getItemPrice(String item) {
    return _itemPrices[item] ?? 0;
  }
}
