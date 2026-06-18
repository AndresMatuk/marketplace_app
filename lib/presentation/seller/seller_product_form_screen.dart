import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/product_categories.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/seller_strings.dart';
import '../../core/utils/product_validators.dart';
import '../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_mutation_provider.dart';
import '../providers/product_mutation_state.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_loading_button.dart';

class SellerProductFormScreen extends ConsumerStatefulWidget {
  const SellerProductFormScreen({
    super.key,
    this.productId,
    this.onSuccess,
    this.onCancel,
  });

  final String? productId;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  bool get isEditMode => productId != null;

  @override
  ConsumerState<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState
    extends ConsumerState<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  ProductCategory? _selectedCategory;
  bool _isActive = true;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _populateForm(Product product) {
    if (_isInitialized) return;

    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _imageUrlController.text = product.imageUrl;
    _selectedCategory = ProductCategory.fromValue(product.category);
    _isActive = product.isActive;
    _isInitialized = true;
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.replaceAll(',', '.'));
    final stock = int.parse(_stockController.text.trim());
    final imageUrl = _imageUrlController.text.trim();
    final category = _selectedCategory!.value;

    final notifier = ref.read(productMutationProvider.notifier);

    if (widget.isEditMode) {
      await notifier.updateProduct(
        id: widget.productId!,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
        isActive: _isActive,
      );
    } else {
      await notifier.createProduct(
        sellerId: user.uid,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
      );
    }
  }

  void _listenMutation(ProductMutationState? previous, ProductMutationState next) {
    if (next is ProductMutationSuccess &&
        (next.type == ProductMutationType.create ||
            next.type == ProductMutationType.update)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message)),
      );
      ref.read(productMutationProvider.notifier).reset();
      widget.onSuccess?.call();
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

    if (widget.isEditMode) {
      ref.listen(
        productDetailProvider(widget.productId!),
        (_, next) {
          next.whenData(_populateForm);
        },
      );

      final detailAsync = ref.watch(productDetailProvider(widget.productId!));

      if (detailAsync.isLoading && !_isInitialized) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditMode
                  ? SellerStrings.editProductTitle
                  : SellerStrings.createProductTitle,
            ),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (detailAsync.hasError && !_isInitialized) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(SellerStrings.editProductTitle),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(SellerStrings.productsError),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(productDetailProvider(widget.productId!).notifier)
                      .refresh(),
                  child: const Text(SellerStrings.retry),
                ),
              ],
            ),
          ),
        );
      }
    }

    final isSubmitting =
        ref.watch(productMutationProvider) is ProductMutationSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode
              ? SellerStrings.editProductTitle
              : SellerStrings.createProductTitle,
        ),
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isSubmitting ? null : widget.onCancel,
              )
            : null,
      ),
      body: SafeArea(
        child: AuthCardContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productName,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outlined),
                  ),
                  validator: ProductValidators.name,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productDescription,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: ProductValidators.description,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productPrice,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: ProductValidators.price,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productStock,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_outlined),
                  ),
                  validator: ProductValidators.stock,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProductCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productCategory,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: ProductCategory.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                      )
                      .toList(),
                  onChanged: isSubmitting
                      ? null
                      : (value) => setState(() => _selectedCategory = value),
                  validator: (_) =>
                      ProductValidators.category(_selectedCategory?.value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: SellerStrings.productImageUrl,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: ProductValidators.imageUrl,
                ),
                if (_imageUrlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: Responsive.isMobile(context) ? 160 : 200,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: _imageUrlController.text.trim(),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (widget.isEditMode) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(SellerStrings.productActive),
                    value: _isActive,
                    onChanged: isSubmitting
                        ? null
                        : (value) => setState(() => _isActive = value),
                  ),
                ],
                const SizedBox(height: 24),
                AuthLoadingButton(
                  label: SellerStrings.saveProduct,
                  isLoading: isSubmitting,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
