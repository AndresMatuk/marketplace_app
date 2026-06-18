import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/customer_strings.dart';
import '../../core/constants/product_categories.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/product.dart';
import '../widgets/cart_app_bar_action.dart';
import '../providers/customer_catalog_provider.dart';
import 'widgets/product_catalog_card.dart';

class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({
    super.key,
    this.onProductTap,
    this.onHomeTap,
    this.onCartTap,
  });

  final void Function(String productId)? onProductTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onCartTap;

  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final _searchController = TextEditingController();
  ProductCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(customerCatalogProvider.notifier).refresh();
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _searchController.text.trim().toLowerCase();

    return products.where((product) {
      final matchesSearch =
          query.isEmpty || product.name.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == null ||
          product.category == _selectedCategory!.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int _crossAxisCount(BuildContext context) {
    if (Responsive.isDesktop(context)) return 4;
    if (Responsive.isTablet(context)) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(customerCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.catalogTitle),
        leading: widget.onHomeTap != null
            ? IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: widget.onHomeTap,
              )
            : null,
        actions: [
          CartAppBarAction(onTap: widget.onCartTap),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: Responsive.screenPadding(context).copyWith(
              bottom: 8,
              top: 8,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: CustomerStrings.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductCategory?>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: CustomerStrings.category,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<ProductCategory?>(
                      value: null,
                      child: Text(CustomerStrings.allCategories),
                    ),
                    ...ProductCategory.values.map(
                      (category) => DropdownMenuItem<ProductCategory?>(
                        value: category,
                        child: Text(category.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: catalogAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => _ErrorView(onRetry: _onRefresh),
              data: (products) {
                final filtered = _filterProducts(products);

                if (filtered.isEmpty) {
                  return _EmptyView(
                    isFiltered: products.isNotEmpty,
                    onRefresh: _onRefresh,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                    padding: Responsive.screenPadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return ProductCatalogCard(
                        product: product,
                        onTap: () => widget.onProductTap?.call(product.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.isFiltered,
    required this.onRefresh,
  });

  final bool isFiltered;
  final Future<void> Function() onRefresh;

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
              isFiltered ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No se encontraron productos'
                  : CustomerStrings.catalogEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRefresh,
                child: const Text(CustomerStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

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
              CustomerStrings.catalogError,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text(CustomerStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
