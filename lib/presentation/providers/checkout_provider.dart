import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/create_order_line.dart';
import '../../domain/entities/order.dart';
import '../../core/utils/order_error_mapper.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'checkout_summary.dart';
import 'customer_catalog_provider.dart';
import 'customer_orders_provider.dart';
import 'order_dependencies.dart';
import 'product_dependencies.dart';

sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutValidating extends CheckoutState {
  const CheckoutValidating();
}

class CheckoutValidated extends CheckoutState {
  const CheckoutValidated(this.summary);

  final CheckoutSummary summary;
}

class CheckoutSubmitting extends CheckoutState {
  const CheckoutSubmitting(this.summary);

  final CheckoutSummary summary;
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);

  final Order order;
}

class CheckoutError extends CheckoutState {
  const CheckoutError({
    required this.message,
    this.summary,
  });

  final String message;
  final CheckoutSummary? summary;
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutInitial();

  Future<void> validateCart() async {
    state = const CheckoutValidating();

    try {
      final cart = ref.read(cartProvider);
      if (cart.isEmpty) {
        state = const CheckoutError(
          message: 'El carrito está vacío.',
        );
        return;
      }

      final productRepository = ref.read(productRepositoryProvider);
      final lines = <CheckoutValidatedLine>[];

      for (final cartItem in cart.items) {
        final product =
            await productRepository.getProductById(id: cartItem.productId);
        final issues = <CheckoutIssue>[];

        if (product == null) {
          issues.add(
            const CheckoutIssue(
              type: CheckoutIssueType.notFound,
              message: 'Producto no encontrado.',
            ),
          );
          lines.add(
            CheckoutValidatedLine(
              cartItem: cartItem,
              currentUnitPrice: cartItem.unitPrice,
              issues: issues,
            ),
          );
          continue;
        }

        if (!product.isActive) {
          issues.add(
            CheckoutIssue(
              type: CheckoutIssueType.inactive,
              message: '"${product.name}" ya no está disponible.',
            ),
          );
        }

        if (product.stock < cartItem.quantity) {
          issues.add(
            CheckoutIssue(
              type: CheckoutIssueType.insufficientStock,
              message:
                  'Stock insuficiente. Disponible: ${product.stock}.',
            ),
          );
        }

        if (product.price != cartItem.unitPrice) {
          issues.add(
            CheckoutIssue(
              type: CheckoutIssueType.priceChanged,
              message:
                  'Precio actualizado: \$${product.price.toStringAsFixed(2)}.',
            ),
          );
        }

        lines.add(
          CheckoutValidatedLine(
            cartItem: cartItem,
            product: product,
            currentUnitPrice: product.price,
            issues: issues,
          ),
        );
      }

      state = CheckoutValidated(CheckoutSummary(lines: lines));
    } catch (error) {
      state = CheckoutError(
        message: OrderErrorMapper.map(error),
      );
    }
  }

  Future<Order?> confirmOrder() async {
    final currentState = state;
    if (currentState is! CheckoutValidated) {
      return null;
    }

    if (!currentState.summary.canConfirm) {
      state = CheckoutError(
        message: 'Corrige los productos antes de confirmar.',
        summary: currentState.summary,
      );
      return null;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const CheckoutError(message: 'Debe iniciar sesión.');
      return null;
    }

    state = CheckoutSubmitting(currentState.summary);

    try {
      final orderRepository = ref.read(orderRepositoryProvider);
      final lines = currentState.summary.lines
          .map(
            (line) => CreateOrderLine(
              productId: line.cartItem.productId,
              quantity: line.cartItem.quantity,
            ),
          )
          .toList();

      final order = await orderRepository.createOrder(
        customerId: user.uid,
        lines: lines,
      );

      ref.read(cartProvider.notifier).clearCart();
      ref.invalidate(customerCatalogProvider);
      ref.invalidate(customerOrdersProvider);

      state = CheckoutSuccess(order);
      return order;
    } catch (error) {
      state = CheckoutError(
        message: OrderErrorMapper.map(error),
        summary: currentState.summary,
      );
      return null;
    }
  }

  void reset() {
    state = const CheckoutInitial();
  }
}

final checkoutProvider =
    NotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);
