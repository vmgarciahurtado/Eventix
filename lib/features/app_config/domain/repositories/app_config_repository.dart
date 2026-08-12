import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';

abstract interface class AppConfigRepository {
  /// Lee la configuración vigente. Falla solo si el asset no se puede leer:
  /// un JSON con campos mal escritos se resuelve con valores por defecto.
  Future<Result<AppConfig>> load();

  /// Olvida lo cacheado para que la próxima [load] vuelva al archivo.
  Future<void> invalidate();
}
