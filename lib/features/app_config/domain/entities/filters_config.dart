/// Qué filtros se ofrecen y cómo se ordenan las categorías.
class FiltersConfig {
  const FiltersConfig({
    required this.cityEnabled,
    required this.dateEnabled,
    required this.pinnedCategories,
    required this.hiddenCategories,
  });

  static const FiltersConfig fallback = FiltersConfig(
    cityEnabled: true,
    dateEnabled: true,
    pinnedCategories: <String>[],
    hiddenCategories: <String>[],
  );

  final bool cityEnabled;
  final bool dateEnabled;

  /// Nombres de categoría que van primero en los chips, en este orden. Las que
  /// no aparezcan aquí conservan el orden del backend.
  final List<String> pinnedCategories;

  /// Nombres de categoría que no se ofrecen, aunque el backend las devuelva.
  final List<String> hiddenCategories;
}
