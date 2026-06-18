import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    debugPrint(
      '[Firestore] fromCache=${doc.metadata.isFromCache} '
      'pendingWrites=${doc.metadata.hasPendingWrites}',
    );
    debugPrint(
      '[Firestore] getUserDocument '
      'fromCache=${doc.metadata.isFromCache} '
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
      '[AuthRemoteDataSource] createUserDocument BEFORE set '
      '| uid=${user.uid} email=${user.email}',
    );

    debugPrint(
      '[FirestoreDebug] projectId=${Firebase.app().options.projectId}',
    );
    debugPrint('[FirestoreDebug] appName=${Firebase.app().name}');
    debugPrint(
      '[FirestoreDebug] firestoreProjectId='
      '${firestore.app.options.projectId}',
    );
    debugPrint('[FirestoreDebug] databaseId=${firestore.databaseId}');
    debugPrint('[FirestoreDebug] collection=$usersCollection');
    debugPrint('[FirestoreDebug] uid=${user.uid}');

    try {
      await firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      debugPrint(
        '[AuthRemoteDataSource] createUserDocument SUCCESS '
        '| uid=${user.uid}',
      );
    } catch (error, stackTrace) {
      debugPrint('[FirestoreDebug] SET FAILED');
      debugPrint('runtimeType=${error.runtimeType}');

      if (error is FirebaseException) {
        debugPrint('code=${error.code}');
        debugPrint('message=${error.message}');
      } else {
        debugPrint('code=');
        debugPrint('message=$error');
      }

      debugPrint(error.toString());
      debugPrint(stackTrace.toString());

      rethrow;
    }
  }
}
