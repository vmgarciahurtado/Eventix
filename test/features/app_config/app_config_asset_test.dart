import 'dart:convert';

import 'package:eventix/core/helpers/hex_color.dart';
import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/asset_app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/mappers/app_config_mapper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Origen que siempre falla, para el camino de arranque sin archivo.
class _BrokenDatasource implements AppConfigDatasource {
  const _BrokenDatasource();

  @override
  Future<JsonMap> fetch() async => throw const FormatException('sin archivo');

  @override
  Future<void> invalidate() async {}
}

/// Recoge el valor de [key] en todo el árbol, a cualquier profundidad.
List<String> valuesOf(Object? node, String key) => switch (node) {
  final Map<String, Object?> map => <String>[
    if (map[key] is String) map[key]! as String,
    for (final Object? child in map.values) ...valuesOf(child, key),
  ],
  final List<Object?> list => <String>[
    for (final Object? child in list) ...valuesOf(child, key),
  ],
  _ => const <String>[],
};

/// Contrato del archivo que se publica: si alguien lo edita mal, esto falla
/// aquí y no en el dispositivo del evaluador.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String source;
  late Map<String, Object?> decoded;
  late AppConfig config;

  setUpAll(() async {
    source = await rootBundle.loadString(AssetAppConfigDatasource.assetPath);
    decoded = jsonDecode(source) as Map<String, Object?>;
    config = AppConfigMapper.toEntity(JsonMap(decoded));
  });

  test('el asset está declarado y es un objeto JSON', () {
    expect(decoded, isNotEmpty);
  });

  test('la versión es la que espera el código', () {
    expect(config.version, AppConfig.fallback.version);
  });

  test('los iconos que nombra existen en el catálogo', () {
    final Set<String> known = AppIcon.values
        .map((AppIcon icon) => icon.name)
        .toSet();

    expect(valuesOf(decoded, 'icon'), everyElement(isIn(known)));
  });

  test('los bloques que nombra existen', () {
    final Set<String> known = HomeBlock.values
        .map((HomeBlock block) => block.name)
        .toSet();

    expect(config.home.blocks, hasLength(HomeBlock.values.length));
    expect(
      (decoded['home']! as Map<String, Object?>)['blocks'],
      everyElement(isIn(known)),
    );
  });

  test('el destino del banner existe', () {
    final List<String> targets = valuesOf(decoded, 'target');

    expect(targets, isNotEmpty);
    expect(
      targets.map(BannerTarget.parse),
      isNot(contains(BannerTarget.none)),
    );
  });

  test('los colores de marca son hex válidos', () {
    for (final String color in <String>['primaryColor', 'secondaryColor']) {
      final Object? raw = (decoded['brand']! as Map<String, Object?>)[color];
      expect(parseArgb(raw as String?), isNotNull, reason: color);
    }
  });

  test('todo texto del archivo trae español e inglés', () {
    // Un idioma a medias haría que la app se vea mezclada.
    void check(Object? node) {
      if (node is Map<String, Object?>) {
        final bool isText = node.values.every((Object? v) => v is String);
        if (isText && node.containsKey('es')) {
          expect(node.keys, containsAll(<String>['es', 'en']));
        }
        node.values.forEach(check);
      } else if (node is List<Object?>) {
        node.forEach(check);
      }
    }

    check(decoded);
  });

  group('arranque', () {
    test('devuelve lo que dice el asset', () async {
      final AppConfig booted = await loadStartupAppConfig();

      expect(booted.version, config.version);
      expect(booted.brand.primaryArgb, config.brand.primaryArgb);
      expect(
        booted.onboarding.slides,
        hasLength(config.onboarding.slides.length),
      );
    });

    test('sin archivo legible arranca con los valores por defecto', () async {
      final AppConfig booted = await loadStartupAppConfig(
        overrides: <Override>[
          appConfigDatasourceProvider.overrideWithValue(
            const _BrokenDatasource(),
          ),
        ],
      );

      expect(booted.brand.tagline, AppConfig.fallback.brand.tagline);
      expect(booted.home.blocks, AppConfig.fallback.home.blocks);
    });
  });
}
