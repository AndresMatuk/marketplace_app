import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/customer_strings.dart';
import '../../core/utils/responsive.dart';
import '../providers/checkout_summary.dart';
import '../providers/checkout_provider.dart';
import '../widgets/auth_loading_button.dart';
import 'widgets/checkout_line_tile.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({
    super.key,
    this.onOrderConfirmed,
    this.onBackTap,
  });

  final void Function(String orderId)? onOrderConfirmed;
  final VoidCallback? onBackTap;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).validateCart();
    });
  }

  Future<void> _confirmOrder() async {
    final order = await ref.read(checkoutProvider.notifier).confirmOrder();
    if (order != null && mounted) {
      widget.onOrderConfirmed?.call(order.id);
    }
  }

  void _listenCheckout(CheckoutState? previous, CheckoutState next) {
    if (next is CheckoutError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checkoutProvider, _listenCheckout);

    final checkoutState = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.checkoutTitle),
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackTap,
              )
            : null,
      ),
      body: switch (checkoutState) {
        CheckoutInitial() || CheckoutValidating() => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(CustomerStrings.checkoutValidating),
              ],
            ),
          ),
        CheckoutValidated(:final summary) ||
        CheckoutSubmitting(:final summary) =>
          _CheckoutContent(
            summary: summary,
            isSubmitting: checkoutState is CheckoutSubmitting,
            onConfirm: _confirmOrder,
          ),
        CheckoutError(:final summary) when summary != null => _CheckoutContent(
            summary: summary,
            isSubmitting: false,
            onConfirm: _confirmOrder,
          ),
        CheckoutError() => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(checkoutProvider.notifier).validateCart(),
                  child: const Text(CustomerStrings.retry),
                ),
              ],
            ),
          ),
        CheckoutSuccess() => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.summary,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final CheckoutSummary summary;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        if (!summary.canConfirm)
          MaterialBanner(
            content: const Text(CustomerStrings.checkoutBlocked),
            leading: Icon(Icons.warning_amber, color: colorScheme.error),
            backgroundColor: colorScheme.errorContainer,
            actions: const [SizedBox.shrink()],
          ),
        Expanded(
          child: ListView.separated(
            padding: Responsive.screenPadding(context),
            itemCount: summary.lines.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return CheckoutLineTile(line: summary.lines[index]);
            },
          ),
        ),
        Container(
          padding: Responsive.screenPadding(context),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CustomerStrings.total, style: theme.textTheme.titleMedium),
                    Text(
                      '\$${summary.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AuthLoadingButton(
                  label: CustomerStrings.confirmOrder,
                  isLoading: isSubmitting,
                  onPressed: summary.canConfirm ? onConfirm : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
