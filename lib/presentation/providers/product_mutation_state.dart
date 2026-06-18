import '../../domain/entities/product.dart';

enum ProductMutationType {
  create,
  update,
  delete,
}

sealed class ProductMutationState {
  const ProductMutationState();
}

class ProductMutationIdle extends ProductMutationState {
  const ProductMutationIdle();
}

class ProductMutationSubmitting extends ProductMutationState {
  const ProductMutationSubmitting();
}

class ProductMutationSuccess extends ProductMutationState {
  const ProductMutationSuccess({
    required this.message,
    required this.type,
    this.product,
    this.deletedProductId,
  });

  final String message;
  final ProductMutationType type;
  final Product? product;
  final String? deletedProductId;
}

class ProductMutationError extends ProductMutationState {
  const ProductMutationError({
    required this.message,
  });

  final String message;
}
