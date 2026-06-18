import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import 'auth_provider.dart';
import 'order_dependencies.dart';

class CustomerOrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final repository = ref.watch(orderRepositoryProvider);
    return repository.getCustomerOrders(customerId: user.uid);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(orderRepositoryProvider);
      return repository.getCustomerOrders(customerId: user.uid);
    });
  }
}

final customerOrdersProvider =
    AsyncNotifierProvider<CustomerOrdersNotifier, List<Order>>(
  CustomerOrdersNotifier.new,
);

class OrderDetailNotifier extends FamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String orderId) async {
    final repository = ref.watch(orderRepositoryProvider);
    final order = await repository.getOrderById(id: orderId);

    if (order == null) {
      throw StateError('Pedido no encontrado.');
    }

    return order;
  }

  Future<void> refresh() async {
    final orderId = arg;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(orderRepositoryProvider);
      final order = await repository.getOrderById(id: orderId);

      if (order == null) {
        throw StateError('Pedido no encontrado.');
      }

      return order;
    });
  }
}

final orderDetailProvider =
    AsyncNotifierProvider.family<OrderDetailNotifier, Order, String>(
  OrderDetailNotifier.new,
);
