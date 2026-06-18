import '../entities/create_order_line.dart';
import '../entities/order.dart';
import '../entities/seller_sale.dart';

abstract class OrderRepository {
  Future<Order> createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required List<CreateOrderLine> lines,
  });

  Future<List<Order>> getCustomerOrders({
    required String customerId,
  });

  Future<List<SellerSale>> getSellerSales({
    required String sellerId,
  });

  Future<Order?> getOrderById({
    required String id,
  });
}
