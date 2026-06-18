import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'product_dependencies.dart';

class ProductDetailNotifier extends FamilyAsyncNotifier<Product, String> {
  @override
  Future<Product> build(String productId) async {
    final repository = ref.watch(productRepositoryProvider);
    final product = await repository.getProductById(id: productId);

    if (product == null) {
      throw StateError('Producto no encontrado.');
    }

    return product;
  }

  Future<void> refresh() async {
    final productId = arg;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.getProductById(id: productId);

      if (product == null) {
        throw StateError('Producto no encontrado.');
      }

      return product;
    });
  }

  void setProduct(Product product) {
    state = AsyncData(product);
  }
}

final productDetailProvider =
    AsyncNotifierProvider.family<ProductDetailNotifier, Product, String>(
  ProductDetailNotifier.new,
);
