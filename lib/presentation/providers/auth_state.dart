import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/utils/auth_error_mapper.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.previous,
  });

  final String message;
  final AuthState? previous;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _authSubscription = _repository.authStateChanges().listen(
      (user) {
        if (_manualAuthFlowInProgress) {
          debugPrint(
            '[AuthNotifier] authStateChanges ignored | manualAuthFlow=true',
          );
          return;
        }

        if (user != null) {
          state = AuthAuthenticated(user);
        } else if (state is! AuthLoading) {
          state = const AuthUnauthenticated();
        }
      },
    );

    loadCurrentUser();
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;
  bool _manualAuthFlowInProgress = false;

  Future<void> loadCurrentUser() async {
    if (state is! AuthAuthenticated) {
      state = const AuthLoading();
    }

    try {
      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (error) {
      state = AuthError(
        message: AuthErrorMapper.map(error),
        previous: const AuthUnauthenticated(),
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      await _repository.signIn(
        email: email,
        password: password,
      );

      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (error) {
      state = AuthError(
        message: AuthErrorMapper.map(error),
        previous: const AuthUnauthenticated(),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _manualAuthFlowInProgress = true;
    state = const AuthLoading();

    try {
      await _repository.signUp(
        name: name,
        email: email,
        password: password,
      );

      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[AuthNotifier] signUp ERROR | error=$error '
        'runtimeType=${error.runtimeType} stackTrace=$stackTrace',
      );

      state = AuthError(
        message: AuthErrorMapper.map(error),
        previous: const AuthUnauthenticated(),
      );
    } finally {
      _manualAuthFlowInProgress = false;
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      await _repository.signOut();
      state = const AuthUnauthenticated();
    } catch (error) {
      state = AuthError(
        message: AuthErrorMapper.map(error),
        previous: state is AuthAuthenticated
            ? state
            : const AuthUnauthenticated(),
      );
    }
  }

  Future<bool> resetPassword({
    required String email,
  }) async {
    try {
      await _repository.resetPassword(email: email);
      return true;
    } catch (error) {
      state = AuthError(
        message: AuthErrorMapper.map(error),
        previous: state is AuthAuthenticated
            ? state
            : const AuthUnauthenticated(),
      );
      return false;
    }
  }

  void clearError() {
    if (state is AuthError) {
      final previous = (state as AuthError).previous;
      state = previous ?? const AuthUnauthenticated();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
