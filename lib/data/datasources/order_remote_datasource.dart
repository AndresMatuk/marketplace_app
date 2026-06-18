import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/order_exception.dart';
import '../../domain/entities/create_order_line.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/seller_sale.dart';
import '../datasources/auth_remote_datasource.dart';
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
    required String customerName,
    required String customerEmail,
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
      final sellerIds = orderItems.map((item) => item.sellerId).toSet().toList();
      final orderModel = OrderModel(
        id: orderRef.id,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        sellerIds: sellerIds,
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

  Future<List<SellerSale>> getSellerSales(String sellerId) async {
    final snapshot = await firestore
        .collection(ordersCollection)
        .where('sellerIds', arrayContains: sellerId)
        .orderBy('createdAt', descending: true)
        .get();

    final orders = snapshot.docs
        .map(
          (doc) => OrderModel.fromMap(
            id: doc.id,
            map: doc.data(),
          ),
        )
        .toList();

    final sales = <SellerSale>[];

    for (final order in orders) {
      final sellerItems = order.items
          .where((item) => item.sellerId == sellerId)
          .map((item) => item.toEntity())
          .toList();

      if (sellerItems.isEmpty) continue;

      var buyerName = order.customerName;
      var buyerEmail = order.customerEmail;

      if (buyerName.isEmpty && order.customerId.isNotEmpty) {
        final userDoc = await firestore
            .collection(AuthRemoteDataSource.usersCollection)
            .doc(order.customerId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          buyerName = userDoc.data()!['name'] as String? ?? '';
          buyerEmail = userDoc.data()!['email'] as String? ?? buyerEmail;
        }
      }

      sales.add(
        SellerSale(
          orderId: order.id,
          buyerName: buyerName.isNotEmpty ? buyerName : 'Cliente',
          buyerEmail: buyerEmail,
          createdAt: order.createdAt?.toDate() ?? DateTime.now(),
          items: sellerItems,
          total: sellerItems.fold(0, (sum, item) => sum + item.lineTotal),
        ),
      );
    }

    return sales;
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
