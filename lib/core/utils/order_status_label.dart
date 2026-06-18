import '../../core/constants/customer_strings.dart';
import '../../domain/entities/order_status.dart';

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return CustomerStrings.statusPending;
    case OrderStatus.confirmed:
      return CustomerStrings.statusConfirmed;
    case OrderStatus.cancelled:
      return CustomerStrings.statusCancelled;
  }
}
