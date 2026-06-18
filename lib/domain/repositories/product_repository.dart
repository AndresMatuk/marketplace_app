import '../entities/product.dart';

abstract class ProductRepository {
  Future<Product> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  });

  Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
    required bool isActive,
  });

  Future<void> deleteProduct({
    required String id,
  });

  Future<List<Product>> getSellerProducts({
    required String sellerId,
  });

  Future<List<Product>> getProducts();

  Future<Product?> getProductById({
    required String id,
  });
}
