/// Categoría de un evento (Música, Tecnología, etc.).
class Category {
  const Category({required this.id, required this.name, required this.slug});

  final int id;
  final String name;
  final String slug;
}
