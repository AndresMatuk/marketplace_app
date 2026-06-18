import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/seller_strings.dart';
import '../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_card_container.dart';

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({
    super.key,
    this.onMyProductsTap,
    this.onCreateProductTap,
  });

  final VoidCallback? onMyProductsTap;
  final VoidCallback? onCreateProductTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? SellerStrings.sellerWelcome;

    return Scaffold(
      appBar: AppBar(
        title: const Text(SellerStrings.sellerHomeTitle),
        actions: [
          IconButton(
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: AuthCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: Responsive.isMobile(context) ? 56 : 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '${SellerStrings.sellerWelcome}, $userName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                SellerStrings.sellerHomeSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: onMyProductsTap,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text(SellerStrings.myProducts),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onCreateProductTap,
                icon: const Icon(Icons.add),
                label: const Text(SellerStrings.createProduct),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.signOutTitle),
        content: const Text(AppStrings.signOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
    }
  }
}
