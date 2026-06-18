import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../errors/order_exception.dart';

class OrderErrorMapper {
  OrderErrorMapper._();

  static String map(Object error) {
    if (error is OrderException) {
      return error.message;
    }

    if (error is FirebaseException) {
      return _mapFirebaseCode(error.code);
    }

    return 'No se pudo procesar el pedido. Intente nuevamente.';
  }

  static String _mapFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'No tiene permisos para realizar esta operación.';
      case 'unavailable':
        return 'El servicio no está disponible. Intente más tarde.';
      case 'aborted':
        return 'La operación fue interrumpida. Intente nuevamente.';
      default:
        return 'Error al procesar el pedido. Intente nuevamente.';
    }
  }
}
