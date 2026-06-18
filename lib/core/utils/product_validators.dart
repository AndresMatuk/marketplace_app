class ProductValidators {
  ProductValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el nombre del producto';
    }
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la descripción del producto';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el precio';
    }
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el stock';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'El stock debe ser mayor o igual a 0';
    }
    return null;
  }

  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione una categoría';
    }
    return null;
  }

  static String? imageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la URL de la imagen';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return 'Ingrese una URL válida';
    }
    return null;
  }
}
