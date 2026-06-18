import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({
    required this.firestore,
  });

  final FirebaseFirestore firestore;

  static const String productsCollection = 'products';

  Future<ProductModel> createProduct(ProductModel product) async {
    final docRef = firestore.collection(productsCollection).doc();
    final productToSave = product.copyWith(id: docRef.id);

    await docRef.set(productToSave.toMap());

    final snapshot = await docRef.get();
    return ProductModel.fromMap(
      id: snapshot.id,
      map: snapshot.data()!,
    );
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final docRef =
        firestore.collection(productsCollection).doc(product.id);

    await docRef.update(product.toUpdateMap());

    final snapshot = await docRef.get();
    return ProductModel.fromMap(
      id: snapshot.id,
      map: snapshot.data()!,
    );
  }

  Future<void> deleteProduct(String id) async {
    await firestore.collection(productsCollection).doc(id).delete();
  }

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    debugPrint(
      '[ProductRemoteDataSource] getSellerProducts '
      'collection=$productsCollection sellerId=$sellerId',
    );

    try {
      final snapshot = await firestore
          .collection(productsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              id: doc.id,
              map: doc.data(),
            ),
          )
          .toList();
    } on FirebaseException catch (error) {
      debugPrint(
        '[ProductRemoteDataSource] getSellerProducts FirebaseException '
        'code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  Future<List<ProductModel>> getActiveProducts() async {
    final snapshot = await firestore
        .collection(productsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => ProductModel.fromMap(
            id: doc.id,
            map: doc.data(),
          ),
        )
        .toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final snapshot =
        await firestore.collection(productsCollection).doc(id).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return ProductModel.fromMap(
      id: snapshot.id,
      map: snapshot.data()!,
    );
  }
}
