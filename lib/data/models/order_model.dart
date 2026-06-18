import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_status.dart';

class OrderItemModel {
  final String productId;
  final String sellerId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemModel({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: (map['lineTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'sellerId': sellerId,
      'name': name,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }

  OrderItem toEntity() {
    return OrderItem(
      productId: productId,
      sellerId: sellerId,
      name: name,
      imageUrl: imageUrl,
      unitPrice: unitPrice,
      quantity: quantity,
      lineTotal: lineTotal,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double total;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.total,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final rawItems = map['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      items: rawItems
          .map(
            (item) => OrderItemModel.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? OrderStatus.pending.value,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'total': total,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  Order toEntity() {
    return Order(
      id: id,
      customerId: customerId,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      total: total,
      status: OrderStatus.fromValue(status),
      createdAt: createdAt?.toDate() ?? DateTime.now(),
      updatedAt: updatedAt?.toDate() ?? DateTime.now(),
    );
  }
}
