import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() {
    return Cart(
      items: const [],
      updatedAt: DateTime.now(),
    );
  }

  void addItem(Product product, {int quantity = 1}) {
    if (quantity <= 0) return;

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.productId == product.id);

    if (index == -1) {
      items.add(
        CartItem(
          productId: product.id,
          quantity: quantity,
          unitPrice: product.price,
          name: product.name,
          imageUrl: product.imageUrl,
          sellerId: product.sellerId,
          addedAt: DateTime.now(),
        ),
      );
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    }

    state = state.copyWith(
      items: items,
      updatedAt: DateTime.now(),
    );
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.productId != productId)
          .toList(),
      updatedAt: DateTime.now(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final items = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: items,
      updatedAt: DateTime.now(),
    );
  }

  void clearCart() {
    state = Cart(
      items: const [],
      updatedAt: DateTime.now(),
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold<double>(0, (sum, item) => sum + item.lineTotal);
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider);
});
