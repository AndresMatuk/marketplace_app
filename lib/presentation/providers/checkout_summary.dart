import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

enum CheckoutIssueType {
  notFound,
  inactive,
  insufficientStock,
  priceChanged,
}

class CheckoutIssue {
  const CheckoutIssue({
    required this.type,
    required this.message,
  });

  final CheckoutIssueType type;
  final String message;
}

class CheckoutValidatedLine {
  const CheckoutValidatedLine({
    required this.cartItem,
    this.product,
    required this.currentUnitPrice,
    required this.issues,
  });

  final CartItem cartItem;
  final Product? product;
  final double currentUnitPrice;
  final List<CheckoutIssue> issues;

  bool get isValid => issues.isEmpty;

  double get lineTotal => currentUnitPrice * cartItem.quantity;

  bool get hasPriceChange =>
      issues.any((issue) => issue.type == CheckoutIssueType.priceChanged);
}

class CheckoutSummary {
  const CheckoutSummary({
    required this.lines,
  });

  final List<CheckoutValidatedLine> lines;

  bool get canConfirm => lines.isNotEmpty && lines.every((line) => line.isValid);

  bool get hasPriceChanges => lines.any((line) => line.hasPriceChange);

  double get subtotal =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  double get total => subtotal;
}
