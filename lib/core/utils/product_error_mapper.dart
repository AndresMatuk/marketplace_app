import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ProductErrorMapper {
  ProductErrorMapper._();

  static String map(Object error) {
    if (error is FirebaseException) {
      return _mapFirebaseCode(error.code);
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Ocurrió un error inesperado. Intente nuevamente.';
  }

  static String _mapFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'No tiene permisos para realizar esta operación.';
      case 'not-found':
        return 'Producto no encontrado.';
      case 'unavailable':
        return 'El servicio no está disponible. Intente más tarde.';
      case 'deadline-exceeded':
        return 'La operación tardó demasiado. Intente nuevamente.';
      case 'failed-precondition':
        return 'La operación no cumple las condiciones requeridas.';
      case 'already-exists':
        return 'El producto ya existe.';
      default:
        return 'Error al procesar el producto. Intente nuevamente.';
    }
  }
}
