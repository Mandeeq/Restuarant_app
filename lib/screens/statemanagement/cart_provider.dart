import 'package:flutter/foundation.dart';
import '../../models/menu_item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<MenuItem> _items = [];

  List<MenuItem> get items => List.unmodifiable(_items);

  double get total =>
      _items.fold(0, (sum, item) => sum + item.price);

  void addItem(MenuItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(MenuItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void insertItem(int index, MenuItem item) {
    _items.insert(index, item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}