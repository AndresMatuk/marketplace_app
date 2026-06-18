class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String customerHome = '/customer/home';
  static const String customerCatalog = '/customer/catalog';
  static const String customerProductDetail = '/customer/product/:id';
  static const String customerCart = '/customer/cart';
  static const String customerCheckout = '/customer/checkout';
  static const String customerOrders = '/customer/orders';
  static const String customerOrderDetail = '/customer/orders/:id';
  static const String customerOrderConfirmation =
      '/customer/orders/:id/confirmation';
  static const String sellerHome = '/seller/home';
  static const String sellerProducts = '/seller/products';
  static const String sellerProductCreate = '/seller/products/new';
  static const String sellerProductEdit = '/seller/products/:id/edit';
  static const String adminHome = '/admin/home';

  static String homeForRole(String role) {
    switch (role) {
      case 'admin':
        return adminHome;
      case 'seller':
        return sellerHome;
      case 'customer':
      default:
        return customerHome;
    }
  }
}
