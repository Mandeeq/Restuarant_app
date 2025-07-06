class Order {
  final String title;
  final double price;
  final int numOfItem;

  Order({
    required this.title,
    required this.price,
    required this.numOfItem,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      title: json['title'],
      price: json['price'].toDouble(),
      numOfItem: json['numOfItem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'numOfItem': numOfItem,
    };
  }
}
