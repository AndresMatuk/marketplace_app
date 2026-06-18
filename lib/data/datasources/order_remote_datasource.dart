import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/order_exception.dart';
import '../../domain/entities/create_order_line.dart';
import '../../domain/entities/order_status.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource({
    required this.firestore,
  });

  final FirebaseFirestore firestore;

  static const String ordersCollection = 'orders';

  Future<OrderModel> createOrder({
    required String customerId,
    required List<CreateOrderLine> lines,
  }) async {
    return firestore.runTransaction((transaction) async {
      final orderItems = <OrderItemModel>[];
      var subtotal = 0.0;

      for (final line in lines) {
        final productRef = firestore
            .collection(ProductRemoteDataSource.productsCollection)
            .doc(line.productId);
        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists || productSnapshot.data() == null) {
          throw OrderException.productNotFound(line.productId);
        }

        final data = productSnapshot.data()!;
        final name = data['name'] as String? ?? '';
        final sellerId = data['sellerId'] as String? ?? '';
        final imageUrl = data['imageUrl'] as String? ?? '';
        final price = (data['price'] as num?)?.toDouble() ?? 0;
        final stock = (data['stock'] as num?)?.toInt() ?? 0;
        final isActive = data['isActive'] as bool? ?? false;

        if (!isActive) {
          throw OrderException.productInactive(name);
        }

        if (stock < line.quantity) {
          throw OrderException.insufficientStock(name);
        }

        transaction.update(productRef, {
          'stock': stock - line.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final lineTotal = price * line.quantity;
        subtotal += lineTotal;

        orderItems.add(
          OrderItemModel(
            productId: line.productId,
            sellerId: sellerId,
            name: name,
            imageUrl: imageUrl,
            unitPrice: price,
            quantity: line.quantity,
            lineTotal: lineTotal,
          ),
        );
      }

      final orderRef = firestore.collection(ordersCollection).doc();
      final orderModel = OrderModel(
        id: orderRef.id,
        customerId: customerId,
        items: orderItems,
        subtotal: subtotal,
        total: subtotal,
        status: OrderStatus.confirmed.value,
      );

      transaction.set(orderRef, orderModel.toMap());

      return orderModel;
    });
  }

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final snapshot = await firestore
        .collection(ordersCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => OrderModel.fromMap(
            id: doc.id,
            map: doc.data(),
          ),
        )
        .toList();
  }

  Future<OrderModel?> getOrderById(String id) async {
    final snapshot = await firestore.collection(ordersCollection).doc(id).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return OrderModel.fromMap(
      id: snapshot.id,
      map: snapshot.data()!,
    );
  }
}
