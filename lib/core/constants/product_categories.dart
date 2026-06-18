enum ProductCategory {
  electronics('electronics', 'Electrónica'),
  clothing('clothing', 'Ropa'),
  home('home', 'Hogar'),
  sports('sports', 'Deportes'),
  books('books', 'Libros'),
  other('other', 'Otros');

  const ProductCategory(this.value, this.label);

  final String value;
  final String label;

  static ProductCategory? fromValue(String? value) {
    if (value == null) return null;
    for (final category in ProductCategory.values) {
      if (category.value == value) return category;
    }
    return null;
  }
}
