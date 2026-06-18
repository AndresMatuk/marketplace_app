import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/customer_strings.dart';
import '../../core/constants/product_categories.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/product.dart';
import '../providers/product_detail_provider.dart';
import '../widgets/auth_loading_button.dart';
import '../widgets/cart_app_bar_action.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.onAddToCart,
    this.onBackTap,
    this.onCartTap,
  });

  final String productId;
  final void Function(Product product)? onAddToCart;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(productId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.productDetail),
        leading: onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackTap,
              )
            : null,
        actions: [
          CartAppBarAction(onTap: onCartTap),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                CustomerStrings.catalogError,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref
                    .read(productDetailProvider(productId).notifier)
                    .refresh(),
                child: const Text(CustomerStrings.retry),
              ),
            ],
          ),
        ),
        data: (product) {
          final categoryLabel =
              ProductCategory.fromValue(product.category)?.label ??
                  product.category;
          final canAddToCart = product.stock > 0;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: Responsive.screenPadding(context),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.isDesktop(context)
                            ? 720
                            : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: product.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => ColoredBox(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          size: 64,
                                        ),
                                      ),
                                    )
                                  : ColoredBox(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      child: const Icon(
                                        Icons.image_outlined,
                                        size: 64,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            product.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(categoryLabel),
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${CustomerStrings.stock}: ${product.stock}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: canAddToCart
                                  ? colorScheme.onSurface
                                  : colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            CustomerStrings.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: Responsive.screenPadding(context),
                  child: AuthLoadingButton(
                    label: canAddToCart
                        ? CustomerStrings.addToCart
                        : CustomerStrings.outOfStock,
                    isLoading: false,
                    onPressed: canAddToCart
                        ? () => onAddToCart?.call(product)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
