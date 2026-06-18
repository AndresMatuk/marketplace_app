class OrderException implements Exception {
  OrderException(this.code, this.message);

  final String code;
  final String message;

  factory OrderException.productNotFound(String productId) {
    return OrderException(
      'product-not-found',
      'El producto $productId no existe.',
    );
  }

  factory OrderException.productInactive(String name) {
    return OrderException(
      'product-inactive',
      'El producto "$name" ya no está disponible.',
    );
  }

  factory OrderException.insufficientStock(String name) {
    return OrderException(
      'insufficient-stock',
      'Stock insuficiente para "$name".',
    );
  }

  @override
  String toString() => message;
}
