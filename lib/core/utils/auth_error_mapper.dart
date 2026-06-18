import 'package:firebase_auth/firebase_auth.dart';

/// Mapea excepciones de Firebase a mensajes legibles para el usuario.
///
/// Usar en la capa de presentación (Notifier / UI).
/// El repositorio y el datasource NO deben usar esta clase.
class AuthErrorMapper {
  AuthErrorMapper._();

  static String map(Object error) {
    if (error is FirebaseAuthException) {
      return _mapAuthCode(error.code);
    }

    if (error is FirebaseException) {
      return _mapFirestoreCode(error.code);
    }

    return 'Ocurrió un error inesperado. Intente nuevamente.';
  }

  // ---------------------------------------------------------------------------
  // Firebase Auth
  // ---------------------------------------------------------------------------

  static String _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifique su correo y contraseña.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet.';
      case 'requires-recent-login':
        return 'Por seguridad, vuelva a iniciar sesión para continuar.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con un método de inicio diferente.';
      default:
        return 'Error de autenticación. Intente nuevamente.';
    }
  }

  // ---------------------------------------------------------------------------
  // Cloud Firestore
  // ---------------------------------------------------------------------------

  static String _mapFirestoreCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'No tiene permisos para realizar esta operación.';
      case 'unavailable':
        return 'El servicio no está disponible. Intente más tarde.';
      case 'not-found':
        return 'No se encontró el recurso solicitado.';
      case 'already-exists':
        return 'El recurso ya existe.';
      case 'deadline-exceeded':
        return 'La operación tardó demasiado. Intente nuevamente.';
      case 'resource-exhausted':
        return 'Se excedió el límite de solicitudes. Intente más tarde.';
      default:
        return 'Error al acceder a los datos. Intente nuevamente.';
    }
  }
}
