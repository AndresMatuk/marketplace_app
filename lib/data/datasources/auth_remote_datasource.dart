import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// Fuente de datos remota para autenticación.
///
/// Encapsula toda la interacción directa con Firebase Auth y Firestore.
/// Las excepciones de Firebase se propagan sin modificar.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required this.auth,
    required this.firestore,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  static const String usersCollection = 'users';

  // ---------------------------------------------------------------------------
  // Firebase Auth
  // ---------------------------------------------------------------------------

  /// Stream nativo de Firebase Auth. Emite `User?` en cada cambio de sesión.
  Stream<User?> authStateChanges() => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => auth.signOut();

  Future<void> resetPassword({
    required String email,
  }) {
    return auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateDisplayName({
    required User user,
    required String name,
  }) {
    return user.updateDisplayName(name.trim());
  }

  Future<void> deleteUser(User user) => user.delete();

  Future<UserCredential> signInWithGoogle() {
    throw UnimplementedError(
      'Google Sign-In será implementado más adelante',
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore
  // ---------------------------------------------------------------------------

  Future<UserModel?> getUserDocument(String uid) async {
    debugPrint(
      '[AuthRemoteDataSource] getUserDocument BEFORE get | uid=$uid',
    );

    final doc = await firestore.collection(usersCollection).doc(uid).get();
    print(
      '[Firestore] fromCache=${doc.metadata.isFromCache} '
      'pendingWrites=${doc.metadata.hasPendingWrites}',
    );
    debugPrint(
      '[AuthRemoteDataSource] getUserDocument AFTER get | uid=$uid '
      'exists=${doc.exists} data=${doc.data()}',
    );

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> createUserDocument(UserModel user) async {
    debugPrint(
      '[AuthRemoteDataSource] createUserDocument BEFORE set | '
      'uid=${user.uid} email=${user.email}',
    );

    try {
      await firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      debugPrint(
        '[AuthRemoteDataSource] createUserDocument AFTER set | uid=${user.uid}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[AuthRemoteDataSource] createUserDocument ERROR | '
        'error=$error runtimeType=${error.runtimeType} stackTrace=$stackTrace',
      );
      rethrow;
    }
  }
}
