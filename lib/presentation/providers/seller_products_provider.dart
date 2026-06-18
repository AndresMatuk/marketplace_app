import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'auth_provider.dart';
import 'product_dependencies.dart';

class SellerProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final repository = ref.watch(productRepositoryProvider);
    return repository.getSellerProducts(sellerId: user.uid);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      return repository.getSellerProducts(sellerId: user.uid);
    });
  }

  void prependProduct(Product product) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData([product, ...current]);
  }

  void upsertProduct(Product product) {
    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      state = AsyncData([product, ...current]);
      return;
    }

    final updated = List<Product>.from(current)..[index] = product;
    state = AsyncData(updated);
  }

  void removeProduct(String productId) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.where((item) => item.id != productId).toList(),
    );
  }
}

final sellerProductsProvider =
    AsyncNotifierProvider<SellerProductsNotifier, List<Product>>(
  SellerProductsNotifier.new,
);
