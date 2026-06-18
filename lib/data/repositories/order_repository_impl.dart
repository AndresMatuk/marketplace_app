import '../../domain/entities/create_order_line.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/seller_sale.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required this.remoteDataSource,
  });

  final OrderRemoteDataSource remoteDataSource;

  @override
  Future<Order> createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required List<CreateOrderLine> lines,
  }) async {
    final order = await remoteDataSource.createOrder(
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      lines: lines,
    );

    return order.toEntity();
  }

  @override
  Future<List<Order>> getCustomerOrders({
    required String customerId,
  }) async {
    final orders = await remoteDataSource.getCustomerOrders(customerId);
    return orders.map((order) => order.toEntity()).toList();
  }

  @override
  Future<List<SellerSale>> getSellerSales({
    required String sellerId,
  }) {
    return remoteDataSource.getSellerSales(sellerId);
  }

  @override
  Future<Order?> getOrderById({
    required String id,
  }) async {
    final order = await remoteDataSource.getOrderById(id);
    return order?.toEntity();
  }
}
