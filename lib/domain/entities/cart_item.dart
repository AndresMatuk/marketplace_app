class CartItem {
  final String productId;
  final int quantity;
  final double unitPrice;
  final String name;
  final String imageUrl;
  final String sellerId;
  final DateTime addedAt;

  const CartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.name,
    required this.imageUrl,
    required this.sellerId,
    required this.addedAt,
  });

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    String? productId,
    int? quantity,
    double? unitPrice,
    String? name,
    String? imageUrl,
    String? sellerId,
    DateTime? addedAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
