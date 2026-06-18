import '../providers/auth_state.dart';
import 'auth_guard.dart';
import 'route_paths.dart';

class RoleGuard {
  RoleGuard._();

  static String? redirect({
    required AuthState authState,
    required String location,
  }) {
    if (authState is! AuthAuthenticated) {
      return null;
    }

    final role = authState.user.role;
    final homeRoute = RoutePaths.homeForRole(role);
    final isSplash = location == RoutePaths.splash;
    final isAuthRoute = AuthGuard.isAuthRoute(location);

    if (isSplash || isAuthRoute) {
      return homeRoute;
    }

    if (location.startsWith('/customer') && role != 'customer') {
      return homeRoute;
    }

    if (location.startsWith('/seller') && role != 'seller') {
      return homeRoute;
    }

    if (location.startsWith('/admin') && role != 'admin') {
      return homeRoute;
    }

    return null;
  }
}
