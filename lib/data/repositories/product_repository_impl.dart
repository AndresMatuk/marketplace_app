import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
  });

  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<Product> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) async {
    final productModel = ProductModel(
      id: '',
      sellerId: sellerId,
      name: name.trim(),
      description: description.trim(),
      price: price,
      stock: stock,
      imageUrl: imageUrl.trim(),
      category: category.trim(),
      isActive: true,
    );

    final created = await remoteDataSource.createProduct(productModel);
    return created.toEntity();
  }

  @override
  Future<Product> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
    required bool isActive,
  }) async {
    final existing = await remoteDataSource.getProductById(id);

    if (existing == null) {
      throw StateError('Producto no encontrado.');
    }

    final updatedModel = existing.copyWith(
      name: name.trim(),
      description: description.trim(),
      price: price,
      stock: stock,
      imageUrl: imageUrl.trim(),
      category: category.trim(),
      isActive: isActive,
    );

    final updated = await remoteDataSource.updateProduct(updatedModel);
    return updated.toEntity();
  }

  @override
  Future<void> deleteProduct({
    required String id,
  }) {
    return remoteDataSource.deleteProduct(id);
  }

  @override
  Future<List<Product>> getSellerProducts({
    required String sellerId,
  }) async {
    final products = await remoteDataSource.getSellerProducts(sellerId);
    return products.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Product>> getProducts() async {
    final products = await remoteDataSource.getActiveProducts();
    return products.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById({
    required String id,
  }) async {
    final product = await remoteDataSource.getProductById(id);
    return product?.toEntity();
  }
}
