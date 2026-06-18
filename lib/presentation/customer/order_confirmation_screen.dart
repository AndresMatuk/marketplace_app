import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/customer_strings.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/order_status_label.dart';
import '../providers/customer_orders_provider.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    this.onViewOrdersTap,
    this.onViewOrderDetailTap,
    this.onBackToCatalogTap,
  });

  final String orderId;
  final VoidCallback? onViewOrdersTap;
  final VoidCallback? onViewOrderDetailTap;
  final VoidCallback? onBackToCatalogTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.orderConfirmationTitle),
        automaticallyImplyLeading: false,
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.read(orderDetailProvider(orderId).notifier).refresh(),
            child: const Text(CustomerStrings.retry),
          ),
        ),
        data: (order) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: Responsive.screenPadding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.contentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        CustomerStrings.orderConfirmationMessage,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${CustomerStrings.orderId}: ${order.id}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${CustomerStrings.total}: \$${order.total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${CustomerStrings.orderDate}: ${dateFormat.format(order.createdAt)}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${CustomerStrings.orderStatus}: ${orderStatusLabel(order.status)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: onViewOrderDetailTap,
                        child: const Text(CustomerStrings.viewOrderDetail),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onViewOrdersTap,
                        child: const Text(CustomerStrings.viewOrders),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onBackToCatalogTap,
                        child: const Text(CustomerStrings.backToCatalog),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
