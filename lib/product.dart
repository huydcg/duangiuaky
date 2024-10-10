// product.dart
class Product {
  String id;
  String name;
  double price;
  int quantity;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<dynamic, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}
