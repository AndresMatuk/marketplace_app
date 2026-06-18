import 'order_item.dart';

class SellerSale {
  final String orderId;
  final String buyerName;
  final String buyerEmail;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double total;

  const SellerSale({
    required this.orderId,
    required this.buyerName,
    required this.buyerEmail,
    required this.createdAt,
    required this.items,
    required this.total,
  });
}
