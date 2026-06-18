import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../providers/checkout_summary.dart';

class CheckoutLineTile extends StatelessWidget {
  const CheckoutLineTile({
    super.key,
    required this.line,
  });

  final CheckoutValidatedLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cartItem = line.cartItem;

    return Card(
      color: line.isValid
          ? null
          : colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: cartItem.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cartItem.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.image_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Cantidad: ${cartItem.quantity}'),
                      Text(
                        'Subtotal: \$${line.lineTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (line.hasPriceChange) ...[
              const SizedBox(height: 8),
              Text(
                'Precio en carrito: \$${cartItem.unitPrice.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Precio actual: \$${line.currentUnitPrice.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (line.issues.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...line.issues.map(
                (issue) => Text(
                  issue.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
