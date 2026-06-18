import '../entities/create_order_line.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> createOrder({
    required String customerId,
    required List<CreateOrderLine> lines,
  });

  Future<List<Order>> getCustomerOrders({
    required String customerId,
  });

  Future<Order?> getOrderById({
    required String id,
  });
}
