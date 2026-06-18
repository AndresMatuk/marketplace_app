class OrderItem {
  final String productId;
  final String sellerId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItem({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });
}
