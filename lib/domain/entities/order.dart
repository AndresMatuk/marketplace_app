import 'order_item.dart';
import 'order_status.dart';

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<String> sellerIds;
  final List<OrderItem> items;
  final double subtotal;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.customerId,
    this.customerName = '',
    this.customerEmail = '',
    this.sellerIds = const [],
    required this.items,
    required this.subtotal,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
