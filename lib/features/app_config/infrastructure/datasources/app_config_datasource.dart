import 'package:eventix/core/helpers/json_map.dart';

/// Origen del JSON de configuración. Hoy es un asset del bundle; cambiarlo por
/// uno remoto es implementar esta interfaz y sustituir un provider del DI.
abstract interface class AppConfigDatasource {
  Future<JsonMap> fetch();

  /// Descarta lo cacheado para que la próxima [fetch] vuelva al origen.
  Future<void> invalidate();
}
