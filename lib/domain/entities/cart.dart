import 'cart_item.dart';

class Cart {
  final List<CartItem> items;
  final DateTime updatedAt;

  const Cart({
    required this.items,
    required this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return Cart(
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
