import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'auth_provider.dart';
import 'product_dependencies.dart';

class SellerProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    try {
      final repository = ref.watch(productRepositoryProvider);
      return await repository.getSellerProducts(sellerId: user.uid);
    } catch (error, stackTrace) {
      debugPrint(
        '[SellerProductsNotifier] build ERROR | error=$error '
        'runtimeType=${error.runtimeType} stackTrace=$stackTrace',
      );
      rethrow;
    }
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

    if (state.hasError) {
      debugPrint(
        '[SellerProductsNotifier] refresh ERROR | error=${state.error} '
        'runtimeType=${state.error?.runtimeType} stackTrace=${state.stackTrace}',
      );
    }
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
