import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/customer_strings.dart';
import '../../core/utils/responsive.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/cart_app_bar_action.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({
    super.key,
    this.onViewCatalogTap,
    this.onOrdersTap,
    this.onCartTap,
  });

  final VoidCallback? onViewCatalogTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final userName = user?.name ?? CustomerStrings.welcome;

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.customerHomeTitle),
        actions: [
          CartAppBarAction(onTap: onCartTap),
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
                Icons.shopping_bag_outlined,
                size: Responsive.isMobile(context) ? 56 : 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '${CustomerStrings.welcome}, $userName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                CustomerStrings.customerHomeSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: onViewCatalogTap,
                icon: const Icon(Icons.storefront_outlined),
                label: const Text(CustomerStrings.viewCatalog),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onOrdersTap,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(CustomerStrings.viewOrders),
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
