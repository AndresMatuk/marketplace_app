import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/product_error_mapper.dart';
import 'customer_catalog_provider.dart';
import 'product_detail_provider.dart';
import 'product_mutation_state.dart';
import '../../domain/entities/product.dart';
import 'product_dependencies.dart';
import 'seller_products_provider.dart';

class ProductMutationNotifier extends Notifier<ProductMutationState> {
  @override
  ProductMutationState build() => const ProductMutationIdle();

  Future<void> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) async {
    state = const ProductMutationSubmitting();

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.createProduct(
        sellerId: sellerId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
      );

      _syncAfterCreate(product);

      state = ProductMutationSuccess(
        message: 'Producto creado correctamente.',
        type: ProductMutationType.create,
        product: product,
      );
    } catch (error) {
      state = ProductMutationError(
        message: ProductErrorMapper.map(error),
      );
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
    required bool isActive,
  }) async {
    state = const ProductMutationSubmitting();

    try {
      final repository = ref.read(productRepositoryProvider);
      final product = await repository.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
        isActive: isActive,
      );

      _syncAfterUpdate(product);

      state = ProductMutationSuccess(
        message: 'Producto actualizado correctamente.',
        type: ProductMutationType.update,
        product: product,
      );
    } catch (error) {
      state = ProductMutationError(
        message: ProductErrorMapper.map(error),
      );
    }
  }

  Future<void> deleteProduct({
    required String id,
  }) async {
    state = const ProductMutationSubmitting();

    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.deleteProduct(id: id);

      _syncAfterDelete(id);

      state = ProductMutationSuccess(
        message: 'Producto eliminado correctamente.',
        type: ProductMutationType.delete,
        deletedProductId: id,
      );
    } catch (error) {
      state = ProductMutationError(
        message: ProductErrorMapper.map(error),
      );
    }
  }

  void reset() {
    state = const ProductMutationIdle();
  }

  void _syncAfterCreate(Product product) {
    ref.read(sellerProductsProvider.notifier).prependProduct(product);

    if (product.isActive) {
      ref.read(customerCatalogProvider.notifier).prependProduct(product);
    }

    ref.read(productDetailProvider(product.id).notifier).setProduct(product);
  }

  void _syncAfterUpdate(Product product) {
    ref.read(sellerProductsProvider.notifier).upsertProduct(product);

    if (product.isActive) {
      ref.read(customerCatalogProvider.notifier).upsertProduct(product);
    } else {
      ref.read(customerCatalogProvider.notifier).removeProduct(product.id);
    }

    ref.read(productDetailProvider(product.id).notifier).setProduct(product);
  }

  void _syncAfterDelete(String productId) {
    ref.read(sellerProductsProvider.notifier).removeProduct(productId);
    ref.read(customerCatalogProvider.notifier).removeProduct(productId);
    ref.invalidate(productDetailProvider(productId));
  }
}

final productMutationProvider =
    NotifierProvider<ProductMutationNotifier, ProductMutationState>(
  ProductMutationNotifier.new,
);
