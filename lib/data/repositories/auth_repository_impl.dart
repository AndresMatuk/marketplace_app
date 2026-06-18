import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementación del repositorio de autenticación.
///
/// Responsabilidades:
/// - Traducir modelos de datos a entidades de dominio.
/// - Orquestar Firebase Auth + Firestore en operaciones compuestas.
/// - Propagar excepciones de Firebase sin transformarlas.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges().asyncMap(
      (firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }

        return _mapFirebaseUserToAppUser(firebaseUser);
      },
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = remoteDataSource.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    return _mapFirebaseUserToAppUser(firebaseUser);
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return remoteDataSource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await remoteDataSource.signUp(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw StateError('Firebase Auth no retornó un usuario tras el registro.');
    }

    try {
      await remoteDataSource.updateDisplayName(
        user: firebaseUser,
        name: name,
      );

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: 'customer',
        photoUrl: '',
      );

      await remoteDataSource.createUserDocument(userModel);
    } catch (error) {
      await remoteDataSource.deleteUser(firebaseUser);
      rethrow;
    }
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) {
    return remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<void> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  Future<AppUser?> _mapFirebaseUserToAppUser(User firebaseUser) async {
    final userModel =
        await remoteDataSource.getUserDocument(firebaseUser.uid);

    return userModel?.toEntity();
  }
}
