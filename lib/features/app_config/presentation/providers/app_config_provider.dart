import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Configuración vigente, siempre resuelta.
///
/// `main()` la sobreescribe con la que leyó del asset; el valor por defecto
/// mantiene la app usable en pruebas y en cualquier lectura sin arranque.
class AppConfigNotifier extends Notifier<AppConfig> {
  AppConfigNotifier([this._initial = AppConfig.fallback]);

  final AppConfig _initial;

  @override
  AppConfig build() => _initial;

  /// Vuelve a leer el asset descartando la caché. Devuelve false si no se pudo
  /// y en ese caso deja la configuración anterior en pie.
  Future<bool> reload() async {
    final Result<AppConfig> result = await ref
        .read(reloadAppConfigProvider)
        .call();
    switch (result) {
      case Success<AppConfig>(:final AppConfig data):
        state = data;
        return true;
      case FailureResult<AppConfig>():
        return false;
    }
  }
}

final NotifierProvider<AppConfigNotifier, AppConfig> appConfigProvider =
    NotifierProvider<AppConfigNotifier, AppConfig>(AppConfigNotifier.new);

/// Override que instala la configuración resuelta en el arranque.
Override appConfigOverride(AppConfig config) =>
    appConfigProvider.overrideWith(() => AppConfigNotifier(config));
