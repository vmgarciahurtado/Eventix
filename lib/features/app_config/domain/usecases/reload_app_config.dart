import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';

/// Descarta la caché del asset y vuelve a leerlo. Es lo que permite ver un
/// cambio del JSON sin reiniciar la app durante el desarrollo.
class ReloadAppConfig {
  const ReloadAppConfig(this._repository);

  final AppConfigRepository _repository;

  Future<Result<AppConfig>> call() async {
    await _repository.invalidate();
    return _repository.load();
  }
}
