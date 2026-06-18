import '../entities/app_user.dart';
abstract class AuthRepository {
  /// Emite el usuario de dominio cuando Firebase Auth detecta sesión activa.
  /// Emite `null` cuando no hay sesión.
  Stream<AppUser?> authStateChanges();

  /// Obtiene el usuario autenticado actual combinando Firebase Auth
  /// con el documento en Firestore (`users/{uid}`).
  /// Retorna `null` si no hay sesión o si el documento no existe.
  Future<AppUser?> getCurrentUser();

  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Crea la cuenta en Firebase Auth y persiste el perfil en Firestore.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({
    required String email,
  });

  Future<void> signInWithGoogle();
}
