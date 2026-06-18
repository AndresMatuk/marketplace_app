import '../providers/auth_state.dart';
import 'route_paths.dart';

class AuthGuard {
  AuthGuard._();

  static bool isAuthRoute(String location) {
    return location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.forgotPassword;
  }

  static bool isLoading(AuthState authState) {
    return authState is AuthInitial || authState is AuthLoading;
  }

  static bool isAuthenticated(AuthState authState) {
    return authState is AuthAuthenticated;
  }

  static String? redirect({
    required AuthState authState,
    required String location,
  }) {
    final isSplash = location == RoutePaths.splash;

    if (isLoading(authState)) {
      return isSplash ? null : RoutePaths.splash;
    }

    if (!isAuthenticated(authState)) {
      if (isSplash || !isAuthRoute(location)) {
        return RoutePaths.login;
      }
      return null;
    }

    return null;
  }
}
