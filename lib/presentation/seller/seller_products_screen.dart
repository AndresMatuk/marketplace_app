import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/seller_strings.dart';
import '../../domain/entities/product.dart';
import '../providers/product_mutation_provider.dart';
import '../providers/product_mutation_state.dart';
import '../providers/seller_products_provider.dart';
import 'widgets/seller_product_card.dart';

class SellerProductsScreen extends ConsumerStatefulWidget {
  const SellerProductsScreen({
    super.key,
    this.onCreateProductTap,
    this.onEditProductTap,
    this.onHomeTap,
  });

  final VoidCallback? onCreateProductTap;
  final void Function(String productId)? onEditProductTap;
  final VoidCallback? onHomeTap;

  @override
  ConsumerState<SellerProductsScreen> createState() =>
      _SellerProductsScreenState();
}

class _SellerProductsScreenState extends ConsumerState<SellerProductsScreen> {
  String? _deletingProductId;

  Future<void> _onRefresh() async {
    await ref.read(sellerProductsProvider.notifier).refresh();
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(SellerStrings.deleteConfirmTitle),
        content: const Text(SellerStrings.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(SellerStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(SellerStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingProductId = product.id);

    await ref.read(productMutationProvider.notifier).deleteProduct(
          id: product.id,
        );

    if (mounted) {
      setState(() => _deletingProductId = null);
    }
  }

  void _listenMutation(ProductMutationState? previous, ProductMutationState next) {
    if (next is ProductMutationSuccess &&
        next.type == ProductMutationType.delete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message)),
      );
      ref.read(productMutationProvider.notifier).reset();
    }

    if (next is ProductMutationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      ref.read(productMutationProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productMutationProvider, _listenMutation);

    final productsAsync = ref.watch(sellerProductsProvider);
    final isSubmitting =
        ref.watch(productMutationProvider) is ProductMutationSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text(SellerStrings.productsTitle),
        leading: widget.onHomeTap != null
            ? IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: widget.onHomeTap,
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSubmitting ? null : widget.onCreateProductTap,
        icon: const Icon(Icons.add),
        label: const Text(SellerStrings.createProduct),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorView(onRetry: _onRefresh),
        data: (products) {
          if (products.isEmpty) {
            return _EmptyView(onCreateTap: widget.onCreateProductTap);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SellerProductCard(
                  product: product,
                  isDeleting: _deletingProductId == product.id,
                  onEditTap: () => widget.onEditProductTap?.call(product.id),
                  onDeleteTap: () => _confirmDelete(product),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({this.onCreateTap});

  final VoidCallback? onCreateTap;

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
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              SellerStrings.productsEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add),
              label: const Text(SellerStrings.productsEmptyAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

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
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              SellerStrings.productsError,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text(SellerStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
