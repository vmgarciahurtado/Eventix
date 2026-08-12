/// Lectura tolerante de un mapa ya decodificado de JSON.
///
/// Cada acceso pide el tipo que espera y devuelve el respaldo si el campo no
/// está o viene con otro tipo. Así un archivo de configuración mal editado
/// degrada a los valores por defecto en vez de tumbar el arranque.
class JsonMap {
  const JsonMap(this.raw);

  /// Envuelve cualquier valor: lo que no sea un objeto JSON se lee vacío.
  factory JsonMap.of(Object? value) => JsonMap(
    value is Map<String, Object?> ? value : const <String, Object?>{},
  );

  static const JsonMap empty = JsonMap(<String, Object?>{});

  final Map<String, Object?> raw;

  bool get isEmpty => raw.isEmpty;

  bool has(String key) => raw.containsKey(key);

  String string(String key, {String fallback = ''}) {
    final Object? value = raw[key];
    return value is String ? value : fallback;
  }

  bool boolean(String key, {required bool fallback}) {
    final Object? value = raw[key];
    return value is bool ? value : fallback;
  }

  int integer(String key, {required int fallback}) {
    final Object? value = raw[key];
    return value is int ? value : fallback;
  }

  /// Objeto anidado. Ausente o de otro tipo devuelve un [JsonMap] vacío, que
  /// a su vez responde con respaldos: nunca hay que comprobar nulos.
  JsonMap child(String key) => JsonMap.of(raw[key]);

  /// Lista de objetos anidados. Los elementos que no sean objetos se ignoran.
  List<JsonMap> children(String key) {
    final Object? value = raw[key];
    if (value is! List<Object?>) return const <JsonMap>[];
    return <JsonMap>[
      for (final Object? item in value)
        if (item is Map<String, Object?>) JsonMap(item),
    ];
  }

  /// Lista de textos, descartando los elementos de otro tipo y los vacíos.
  List<String> strings(String key) {
    final Object? value = raw[key];
    if (value is! List<Object?>) return const <String>[];
    return <String>[
      for (final Object? item in value)
        if (item is String && item.trim().isNotEmpty) item,
    ];
  }

  /// Mapa de textos, para los campos traducidos del archivo.
  Map<String, String> stringMap(String key) {
    final Object? value = raw[key];
    if (value is! Map<String, Object?>) return const <String, String>{};
    return <String, String>{
      for (final MapEntry<String, Object?> entry in value.entries)
        if (entry.value is String) entry.key: entry.value! as String,
    };
  }
}
