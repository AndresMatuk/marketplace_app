import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  bool _signUpInProgress = false;

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges().asyncMap(
      (firebaseUser) async {
        if (firebaseUser == null) {
          return null;
        }

        if (_signUpInProgress) {
          debugPrint(
            '[AuthRepositoryImpl] authStateChanges skipped getUserDocument '
            '| uid=${firebaseUser.uid} signUpInProgress=true',
          );
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
    _signUpInProgress = true;

    debugPrint(
      '[AuthRepositoryImpl] signUp BEFORE createUserWithEmailAndPassword | '
      'email=$email',
    );

    try {
      final credential = await remoteDataSource.signUp(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      debugPrint(
        '[AuthRepositoryImpl] signUp AFTER createUserWithEmailAndPassword | '
        'uid=${firebaseUser?.uid} email=${firebaseUser?.email ?? email}',
      );

      if (firebaseUser == null) {
        throw StateError('Firebase Auth no retornó un usuario tras el registro.');
      }

      try {
        debugPrint(
          '[AuthRepositoryImpl] signUp BEFORE updateDisplayName | '
          'uid=${firebaseUser.uid} email=${firebaseUser.email}',
        );

        await remoteDataSource.updateDisplayName(
          user: firebaseUser,
          name: name,
        );

        debugPrint(
          '[AuthRepositoryImpl] signUp AFTER updateDisplayName | '
          'uid=${firebaseUser.uid}',
        );

        final userModel = UserModel(
          uid: firebaseUser.uid,
          name: name.trim(),
          email: email.trim(),
          role: 'customer',
          photoUrl: '',
        );

        debugPrint(
          '[AuthRepositoryImpl] signUp BEFORE createUserDocument | '
          'uid=${firebaseUser.uid} email=${userModel.email}',
        );

        await remoteDataSource.createUserDocument(userModel);

        debugPrint(
          '[AuthRepositoryImpl] signUp AFTER createUserDocument | '
          'uid=${firebaseUser.uid}',
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[AuthRepositoryImpl] signUp ERROR before rollback | '
          'uid=${firebaseUser.uid} email=${firebaseUser.email} '
          'error=$error stackTrace=$stackTrace',
        );

        debugPrint(
          '[AuthRepositoryImpl] signUp BEFORE deleteUser | uid=${firebaseUser.uid}',
        );

        try {
          await remoteDataSource.deleteUser(firebaseUser);

          debugPrint(
            '[AuthRepositoryImpl] signUp AFTER deleteUser | uid=${firebaseUser.uid}',
          );
        } catch (rollbackError, rollbackStackTrace) {
          debugPrint(
            '[AuthRepositoryImpl] signUp rollback deleteUser FAILED | '
            'uid=${firebaseUser.uid} rollbackError=$rollbackError '
            'rollbackStackTrace=$rollbackStackTrace',
          );
        }

        Error.throwWithStackTrace(error, stackTrace);
      }
    } finally {
      _signUpInProgress = false;
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
