import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../admin/admin_home_screen.dart';
import '../../core/constants/customer_strings.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../customer/cart_screen.dart';
import '../customer/checkout_screen.dart';
import '../customer/customer_home_screen.dart';
import '../customer/order_confirmation_screen.dart';
import '../customer/order_detail_screen.dart';
import '../customer/orders_screen.dart';
import '../customer/product_catalog_screen.dart';
import '../customer/product_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../providers/cart_provider.dart';
import '../seller/seller_home_screen.dart';
import '../seller/seller_product_form_screen.dart';
import '../seller/seller_products_screen.dart';
import '../splash/splash_screen.dart';
import 'auth_guard.dart';
import 'role_guard.dart';
import 'route_names.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: _AuthRouterRefresh(ref),
    redirect: (context, state) {
      final location = state.matchedLocation;

      return AuthGuard.redirect(
            authState: authState,
            location: location,
          ) ??
          RoleGuard.redirect(
            authState: authState,
            location: location,
          );
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => LoginScreen(
          onRegisterTap: () => context.pushNamed(RouteNames.register),
          onForgotPasswordTap: () =>
              context.pushNamed(RouteNames.forgotPassword),
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => RegisterScreen(
          onLoginTap: () => context.goNamed(RouteNames.login),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => ForgotPasswordScreen(
          onBackToLoginTap: () => context.goNamed(RouteNames.login),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerHome,
        name: RouteNames.customerHome,
        builder: (context, state) => CustomerHomeScreen(
          onViewCatalogTap: () =>
              context.pushNamed(RouteNames.customerCatalog),
          onOrdersTap: () => context.pushNamed(RouteNames.customerOrders),
          onCartTap: () => context.pushNamed(RouteNames.customerCart),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerCatalog,
        name: RouteNames.customerCatalog,
        builder: (context, state) => ProductCatalogScreen(
          onProductTap: (productId) => context.pushNamed(
            RouteNames.customerProductDetail,
            pathParameters: {'id': productId},
          ),
          onHomeTap: () => context.goNamed(RouteNames.customerHome),
          onCartTap: () => context.pushNamed(RouteNames.customerCart),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerProductDetail,
        name: RouteNames.customerProductDetail,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(
            productId: productId,
            onBackTap: () => context.pop(),
            onCartTap: () => context.pushNamed(RouteNames.customerCart),
            onAddToCart: (product) {
              ref.read(cartProvider.notifier).addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${CustomerStrings.addedToCart}: ${product.name}',
                  ),
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.customerCart,
        name: RouteNames.customerCart,
        builder: (context, state) => CartScreen(
          onContinueShoppingTap: () =>
              context.goNamed(RouteNames.customerCatalog),
          onCheckoutTap: () => context.pushNamed(RouteNames.customerCheckout),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerCheckout,
        name: RouteNames.customerCheckout,
        builder: (context, state) => CheckoutScreen(
          onBackTap: () => context.pop(),
          onOrderConfirmed: (orderId) => context.goNamed(
            RouteNames.customerOrderConfirmation,
            pathParameters: {'id': orderId},
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerOrders,
        name: RouteNames.customerOrders,
        builder: (context, state) => OrdersScreen(
          onHomeTap: () => context.goNamed(RouteNames.customerHome),
          onOrderTap: (orderId) => context.pushNamed(
            RouteNames.customerOrderDetail,
            pathParameters: {'id': orderId},
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.customerOrderConfirmation,
        name: RouteNames.customerOrderConfirmation,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderConfirmationScreen(
            orderId: orderId,
            onViewOrderDetailTap: () => context.goNamed(
              RouteNames.customerOrderDetail,
              pathParameters: {'id': orderId},
            ),
            onViewOrdersTap: () => context.goNamed(RouteNames.customerOrders),
            onBackToCatalogTap: () =>
                context.goNamed(RouteNames.customerCatalog),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.customerOrderDetail,
        name: RouteNames.customerOrderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(
            orderId: orderId,
            onBackTap: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.sellerHome,
        name: RouteNames.sellerHome,
        builder: (context, state) => SellerHomeScreen(
          onMyProductsTap: () =>
              context.pushNamed(RouteNames.sellerProducts),
          onCreateProductTap: () =>
              context.pushNamed(RouteNames.sellerProductCreate),
        ),
      ),
      GoRoute(
        path: RoutePaths.sellerProducts,
        name: RouteNames.sellerProducts,
        builder: (context, state) => SellerProductsScreen(
          onCreateProductTap: () =>
              context.pushNamed(RouteNames.sellerProductCreate),
          onEditProductTap: (productId) => context.pushNamed(
            RouteNames.sellerProductEdit,
            pathParameters: {'id': productId},
          ),
          onHomeTap: () => context.goNamed(RouteNames.sellerHome),
        ),
      ),
      GoRoute(
        path: RoutePaths.sellerProductCreate,
        name: RouteNames.sellerProductCreate,
        builder: (context, state) => SellerProductFormScreen(
          onSuccess: () => context.goNamed(RouteNames.sellerProducts),
          onCancel: () => context.pop(),
        ),
      ),
      GoRoute(
        path: RoutePaths.sellerProductEdit,
        name: RouteNames.sellerProductEdit,
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return SellerProductFormScreen(
            productId: productId,
            onSuccess: () => context.goNamed(RouteNames.sellerProducts),
            onCancel: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.adminHome,
        name: RouteNames.adminHome,
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(this._ref) {
    _subscription = _ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
