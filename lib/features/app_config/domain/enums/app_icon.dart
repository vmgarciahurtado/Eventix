/// Iconos que el JSON puede pedir por nombre.
///
/// Es un catálogo cerrado a propósito: `IconData` construido desde un code
/// point del archivo obligaría a compilar con `--no-tree-shake-icons`. El
/// nombre del JSON se resuelve aquí y la presentación traduce cada valor a su
/// `IconData`.
enum AppIcon {
  explore,
  filter,
  ticket,
  party,
  music,
  calendar,
  location,
  star;

  /// [name] desconocido o ausente cae en [fallback] en vez de romper el parseo.
  static AppIcon parse(String? name, {AppIcon fallback = AppIcon.star}) {
    for (final AppIcon icon in AppIcon.values) {
      if (icon.name == name) return icon;
    }
    return fallback;
  }
}
