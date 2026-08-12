/// Texto del JSON de configuración en varios idiomas, indexado por código de
/// idioma. El ARB sigue siendo el dueño de los textos de la interfaz; esto es
/// solo para el contenido que el negocio edita sin recompilar.
class LocalizedText {
  const LocalizedText(this.values);

  /// Idioma base del archivo: al que se cae si el pedido no está.
  static const String fallbackLanguage = 'es';

  static const LocalizedText empty = LocalizedText(<String, String>{});

  final Map<String, String> values;

  /// Devuelve el texto del idioma pedido, o el del idioma base, o el primero
  /// que haya. Nunca es nulo: un texto ausente se ve vacío, no rompe.
  String resolve(String languageCode) =>
      values[languageCode] ??
      values[fallbackLanguage] ??
      (values.isEmpty ? '' : values.values.first);

  @override
  bool operator ==(Object other) {
    if (other is! LocalizedText) return false;
    if (other.values.length != values.length) return false;
    for (final MapEntry<String, String> entry in values.entries) {
      if (other.values[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    values.entries.map(
      (MapEntry<String, String> e) => Object.hash(e.key, e.value),
    ),
  );

  @override
  String toString() => 'LocalizedText($values)';
}
