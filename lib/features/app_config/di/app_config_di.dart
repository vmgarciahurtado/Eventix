import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/services/assets/asset_bundle_provider.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';
import 'package:eventix/features/app_config/domain/usecases/get_app_config.dart';
import 'package:eventix/features/app_config/domain/usecases/reload_app_config.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/asset_app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/repositories/app_config_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Composition root de la configuración. Cambiar el asset por un origen remoto
/// es sobreescribir [appConfigDatasourceProvider] y nada más.
final Provider<AppConfigDatasource> appConfigDatasourceProvider =
    Provider<AppConfigDatasource>(
      (Ref ref) => AssetAppConfigDatasource(ref.watch(assetBundleProvider)),
    );

final Provider<AppConfigRepository> appConfigRepositoryProvider =
    Provider<AppConfigRepository>(
      (Ref ref) =>
          AppConfigRepositoryImpl(ref.watch(appConfigDatasourceProvider)),
    );

final Provider<GetAppConfig> getAppConfigProvider = Provider<GetAppConfig>(
  (Ref ref) => GetAppConfig(ref.watch(appConfigRepositoryProvider)),
);

final Provider<ReloadAppConfig> reloadAppConfigProvider =
    Provider<ReloadAppConfig>(
      (Ref ref) => ReloadAppConfig(ref.watch(appConfigRepositoryProvider)),
    );

/// Resuelve la configuración antes de `runApp` para que el resto de la app la
/// lea de forma síncrona: ninguna pantalla tiene que manejar un estado de
/// carga por esto. Un asset ausente o ilegible deja la app en pie con
/// [AppConfig.fallback].
///
/// [overrides] existe para poder darle otro origen en las pruebas.
Future<AppConfig> loadStartupAppConfig({
  List<Override> overrides = const <Override>[],
}) async {
  final ProviderContainer container = ProviderContainer(overrides: overrides);
  try {
    final Result<AppConfig> result = await container
        .read(getAppConfigProvider)
        .call();
    return switch (result) {
      Success<AppConfig>(:final AppConfig data) => data,
      FailureResult<AppConfig>() => AppConfig.fallback,
    };
  } finally {
    container.dispose();
  }
}
