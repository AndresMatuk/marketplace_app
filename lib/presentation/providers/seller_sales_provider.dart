import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seller_sale.dart';
import 'auth_provider.dart';
import 'order_dependencies.dart';

class SellerSalesNotifier extends AsyncNotifier<List<SellerSale>> {
  @override
  Future<List<SellerSale>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final repository = ref.watch(orderRepositoryProvider);
    return repository.getSellerSales(sellerId: user.uid);
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
      return repository.getSellerSales(sellerId: user.uid);
    });
  }
}

final sellerSalesProvider =
    AsyncNotifierProvider<SellerSalesNotifier, List<SellerSale>>(
  SellerSalesNotifier.new,
);
