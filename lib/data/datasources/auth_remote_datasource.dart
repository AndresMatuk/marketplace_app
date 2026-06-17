import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource({
    required this.auth,
    required this.firestore,
  });

  Stream<User?> authStateChanges() {
    return auth.authStateChanges();
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await auth.sendPasswordResetEmail(
      email: email,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
  throw UnimplementedError(
    'Google Sign-In será implementado más adelante',
  );
}
}