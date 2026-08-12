import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_container.dart';

/// Origen en memoria que puede cambiar entre lecturas y fallar a voluntad.
class _SwappableDatasource implements AppConfigDatasource {
  _SwappableDatasource(this.json);

  JsonMap json;
  bool broken = false;
  int invalidations = 0;

  @override
  Future<JsonMap> fetch() async {
    if (broken) throw const FormatException('json roto');
    return json;
  }

  @override
  Future<void> invalidate() async => invalidations++;
}

void main() {
  late _SwappableDatasource datasource;
  late ProviderContainer container;

  setUp(() {
    datasource = _SwappableDatasource(
      const JsonMap(<String, Object?>{'version': 1}),
    );
    container = testContainer(
      overrides: <Override>[
        appConfigDatasourceProvider.overrideWithValue(datasource),
      ],
    );
    keepAlive(container, appConfigProvider);
    addTearDown(container.dispose);
  });

  test('sin arranque queda la configuración por defecto', () {
    expect(container.read(appConfigProvider).version, 1);
    expect(
      container.read(appConfigProvider).home.blocks,
      AppConfig.fallback.home.blocks,
    );
  });

  test('el override del arranque instala la que se leyó', () {
    final ProviderContainer booted = testContainer(
      overrides: <Override>[appConfigOverride(tAppConfig(version: 9))],
    );
    addTearDown(booted.dispose);

    expect(booted.read(appConfigProvider).version, 9);
  });

  group('recarga', () {
    test('trae los cambios del archivo y avisa que salió bien', () async {
      datasource.json = const JsonMap(<String, Object?>{
        'brand': <String, Object?>{'primaryColor': '#123456'},
      });

      final bool reloaded = await container
          .read(appConfigProvider.notifier)
          .reload();

      expect(reloaded, isTrue);
      expect(container.read(appConfigProvider).brand.primaryArgb, 0xFF123456);
      expect(datasource.invalidations, 1);
    });

    test('si falla deja la configuración anterior en pie', () async {
      datasource.broken = true;

      final bool reloaded = await container
          .read(appConfigProvider.notifier)
          .reload();

      expect(reloaded, isFalse);
      expect(container.read(appConfigProvider).version, 1);
    });
  });
}
