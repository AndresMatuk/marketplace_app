import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges().asyncMap(
      (user) async {
        if (user == null) return null;

        return getCurrentUser();
      },
    );
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;

    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await remoteDataSource.signIn(
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

  print('PASO 1');

  final credential =
      await remoteDataSource.signUp(
    email: email,
    password: password,
  );

  print('PASO 2');

  await FirebaseFirestore.instance
      .collection('users')
      .doc(credential.user!.uid)
      .set({
    'uid': credential.user!.uid,
    'name': name,
    'email': email,
    'role': 'customer',
    'photoUrl': '',
    'createdAt': FieldValue.serverTimestamp(),
  });

  print('PASO 3');
}

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError();
  }
}