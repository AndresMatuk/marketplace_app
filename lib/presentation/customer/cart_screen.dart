import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/customer_strings.dart';
import '../../core/utils/responsive.dart';
import '../providers/cart_provider.dart';
import '../widgets/auth_loading_button.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({
    super.key,
    this.onContinueShoppingTap,
    this.onCheckoutTap,
  });

  final VoidCallback? onContinueShoppingTap;
  final VoidCallback? onCheckoutTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final total = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.cartTitle),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              onPressed: () => _confirmClearCart(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: CustomerStrings.clearCart,
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCartView(onContinueShoppingTap: onContinueShoppingTap)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: Responsive.screenPadding(context),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final notifier = ref.read(cartProvider.notifier);

                      return CartItemTile(
                        item: item,
                        onIncrease: () => notifier.updateQuantity(
                          item.productId,
                          item.quantity + 1,
                        ),
                        onDecrease: () => notifier.updateQuantity(
                          item.productId,
                          item.quantity - 1,
                        ),
                        onRemove: () => notifier.removeItem(item.productId),
                      );
                    },
                  ),
                ),
                _CartSummaryFooter(
                  subtotal: subtotal,
                  total: total,
                  onCheckoutTap: onCheckoutTap,
                ),
              ],
            ),
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(CustomerStrings.clearCartTitle),
        content: const Text(CustomerStrings.clearCartMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CustomerStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(CustomerStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(cartProvider.notifier).clearCart();
    }
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({this.onContinueShoppingTap});

  final VoidCallback? onContinueShoppingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              CustomerStrings.cartEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onContinueShoppingTap,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text(CustomerStrings.continueShopping),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummaryFooter extends StatelessWidget {
  const _CartSummaryFooter({
    required this.subtotal,
    required this.total,
    this.onCheckoutTap,
  });

  final double subtotal;
  final double total;
  final VoidCallback? onCheckoutTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: Responsive.screenPadding(context),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryRow(
              label: CustomerStrings.subtotal,
              value: subtotal,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: CustomerStrings.total,
              value: total,
              isTotal: true,
            ),
            if (onCheckoutTap != null) ...[
              const SizedBox(height: 16),
              AuthLoadingButton(
                label: CustomerStrings.checkout,
                isLoading: false,
                onPressed: onCheckoutTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyLarge,
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
