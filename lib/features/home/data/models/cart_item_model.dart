class CartItemModel {
  final int id;
  final String name;
  final double price;
  final int garageId;
  int quantity;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.garageId,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {'id': id, 'quantity': quantity};
}
