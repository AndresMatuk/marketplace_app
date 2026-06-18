import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/customer_strings.dart';
import '../../domain/entities/order.dart';
import '../providers/customer_orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({
    super.key,
    this.onOrderTap,
    this.onHomeTap,
  });

  final void Function(String orderId)? onOrderTap;
  final VoidCallback? onHomeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomerStrings.ordersTitle),
        leading: onHomeTap != null
            ? IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: onHomeTap,
              )
            : null,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton(
            onPressed: () =>
                ref.read(customerOrdersProvider.notifier).refresh(),
            child: const Text(CustomerStrings.retry),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    CustomerStrings.ordersEmpty,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(customerOrdersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(
                  order: order,
                  dateFormat: dateFormat,
                  onTap: () => onOrderTap?.call(order.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.dateFormat,
    this.onTap,
  });

  final Order order;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text('Pedido #${order.id.substring(0, 8)}'),
        subtitle: Text(dateFormat.format(order.createdAt)),
        trailing: Text(
          '\$${order.total.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
