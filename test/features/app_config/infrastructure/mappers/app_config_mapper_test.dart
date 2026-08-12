import 'dart:convert';

import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/entities/brand_config.dart';
import 'package:eventix/features/app_config/domain/entities/home_config.dart';
import 'package:eventix/features/app_config/domain/entities/onboarding_config.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';
import 'package:eventix/features/app_config/infrastructure/mappers/app_config_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parsea el JSON como llega del archivo, sin construir mapas a mano.
AppConfig parse(String source) =>
    AppConfigMapper.toEntity(JsonMap.of(jsonDecode(source)));

void main() {
  group('archivo completo', () {
    final AppConfig config = parse('''
    {
      "version": 3,
      "brand": {
        "tagline": {"es": "Vive la noche", "en": "Live the night"},
        "primaryColor": "#00FF00",
        "secondaryColor": "#0000FF"
      },
      "onboarding": {
        "slides": [
          {"icon": "music", "title": {"es": "Suena"}, "body": {"es": "Duro"}}
        ]
      },
      "home": {
        "blocks": ["filters", "events", "banner"],
        "banner": {
          "enabled": true,
          "icon": "ticket",
          "title": {"es": "Promo"},
          "subtitle": {"es": "Solo hoy"},
          "action": {"label": {"es": "Ver"}, "target": "reservations"}
        },
        "emptyState": {"title": {"es": "Nada"}, "message": {"es": "Aún no"}}
      },
      "filters": {
        "cityEnabled": false,
        "dateEnabled": true,
        "pinnedCategories": ["Techno"],
        "hiddenCategories": ["Infantil"]
      }
    }
    ''');

    test('lee la versión del contrato', () {
      expect(config.version, 3);
    });

    test('lee la marca con sus dos acentos', () {
      expect(config.brand.tagline.resolve('en'), 'Live the night');
      expect(config.brand.primaryArgb, 0xFF00FF00);
      expect(config.brand.secondaryArgb, 0xFF0000FF);
    });

    test('lee las láminas del onboarding', () {
      expect(config.onboarding.slides, hasLength(1));
      expect(config.onboarding.slides.first.icon, AppIcon.music);
      expect(config.onboarding.slides.first.title.resolve('es'), 'Suena');
    });

    test('respeta el orden de los bloques del archivo', () {
      expect(config.home.blocks, <HomeBlock>[
        HomeBlock.filters,
        HomeBlock.events,
        HomeBlock.banner,
      ]);
    });

    test('lee el banner con su botón', () {
      expect(config.home.banner.enabled, isTrue);
      expect(config.home.banner.icon, AppIcon.ticket);
      expect(config.home.banner.action?.target, BannerTarget.reservations);
      expect(config.home.banner.action?.label.resolve('es'), 'Ver');
    });

    test('lee el estado vacío', () {
      expect(config.home.emptyState.title.resolve('es'), 'Nada');
      expect(config.home.emptyState.message.resolve('es'), 'Aún no');
    });

    test('lee los filtros', () {
      expect(config.filters.cityEnabled, isFalse);
      expect(config.filters.dateEnabled, isTrue);
      expect(config.filters.pinnedCategories, <String>['Techno']);
      expect(config.filters.hiddenCategories, <String>['Infantil']);
    });
  });

  group('archivo vacío', () {
    test('un objeto sin claves reproduce los valores por defecto', () {
      final AppConfig config = parse('{}');

      expect(config.version, AppConfig.fallback.version);
      expect(config.brand.primaryArgb, BrandConfig.fallback.primaryArgb);
      expect(config.brand.tagline, BrandConfig.fallback.tagline);
      expect(config.onboarding.slides, hasLength(3));
      expect(config.home.blocks, HomeBlock.fallback);
      expect(config.home.banner.enabled, isFalse);
      expect(
        config.home.emptyState.title,
        EmptyStateConfig.fallback.title,
      );
      expect(config.filters.cityEnabled, isTrue);
      expect(config.filters.pinnedCategories, isEmpty);
    });

    test('un archivo que no es un objeto se lee igual que uno vacío', () {
      expect(parse('[1, 2, 3]').home.blocks, HomeBlock.fallback);
    });
  });

  group('tolerancia a errores de edición', () {
    test('los tipos cambiados caen a los valores por defecto', () {
      final AppConfig config = parse('''
      {
        "version": "tres",
        "brand": "amarillo",
        "home": {"blocks": "banner", "banner": 7},
        "filters": {"cityEnabled": "sí", "pinnedCategories": "Techno"}
      }
      ''');

      expect(config.version, AppConfig.fallback.version);
      expect(config.brand.primaryArgb, BrandConfig.fallback.primaryArgb);
      expect(config.home.blocks, HomeBlock.fallback);
      expect(config.home.banner.enabled, isFalse);
      expect(config.filters.cityEnabled, isTrue);
      expect(config.filters.pinnedCategories, isEmpty);
    });

    test('un color mal escrito no cambia la marca', () {
      final AppConfig config = parse(
        '{"brand": {"primaryColor": "casi-amarillo"}}',
      );

      expect(config.brand.primaryArgb, BrandConfig.fallback.primaryArgb);
    });

    test('un icono desconocido no deja la lámina sin dibujo', () {
      final AppConfig config = parse('''
      {"onboarding": {"slides": [{"icon": "ovni", "title": {"es": "A"}}]}}
      ''');

      expect(config.onboarding.slides.single.icon, AppIcon.star);
    });

    test('un texto plano vale como atajo del idioma base', () {
      final AppConfig config = parse('{"brand": {"tagline": "Solo español"}}');

      expect(config.brand.tagline.resolve('es'), 'Solo español');
      expect(config.brand.tagline.resolve('en'), 'Solo español');
    });

    test('un texto en blanco no pisa el valor por defecto', () {
      final AppConfig config = parse('{"brand": {"tagline": "   "}}');

      expect(config.brand.tagline, BrandConfig.fallback.tagline);
    });
  });

  group('bloques de la pantalla', () {
    test('los nombres desconocidos se ignoran', () {
      final AppConfig config = parse(
        '{"home": {"blocks": ["carrusel", "events"]}}',
      );

      expect(config.home.blocks, <HomeBlock>[HomeBlock.events]);
    });

    test('los repetidos se pintan una sola vez', () {
      final AppConfig config = parse(
        '{"home": {"blocks": ["events", "events", "banner"]}}',
      );

      expect(config.home.blocks, <HomeBlock>[
        HomeBlock.events,
        HomeBlock.banner,
      ]);
    });

    test('omitir la lista de eventos no deja la pantalla sin contenido', () {
      final AppConfig config = parse('{"home": {"blocks": ["banner"]}}');

      expect(config.home.blocks, <HomeBlock>[
        HomeBlock.banner,
        HomeBlock.events,
      ]);
    });

    test('una lista vacía cae al orden por defecto', () {
      final AppConfig config = parse('{"home": {"blocks": []}}');

      expect(config.home.blocks, HomeBlock.fallback);
    });
  });

  group('botón del banner', () {
    test('sin etiqueta no se pinta el botón', () {
      final AppConfig config = parse('''
      {"home": {"banner": {"enabled": true, "action": {"target": "events"}}}}
      ''');

      expect(config.home.banner.action, isNull);
    });

    test('con un destino desconocido tampoco', () {
      final AppConfig config = parse('''
      {"home": {"banner": {"action": {"label": {"es": "Ir"}, "target": "x"}}}}
      ''');

      expect(config.home.banner.action, isNull);
    });

    test('sin bloque de acción el banner queda sin botón', () {
      final AppConfig config = parse(
        '{"home": {"banner": {"enabled": true}}}',
      );

      expect(config.home.banner.action, isNull);
      expect(config.home.banner.enabled, isTrue);
    });
  });

  group('onboarding', () {
    test('las láminas sin título se descartan', () {
      final AppConfig config = parse('''
      {"onboarding": {"slides": [
        {"icon": "music"},
        {"icon": "party", "title": {"es": "Vale"}}
      ]}}
      ''');

      expect(config.onboarding.slides, hasLength(1));
      expect(config.onboarding.slides.single.icon, AppIcon.party);
    });

    test('quedarse sin láminas legibles cae a las por defecto', () {
      final AppConfig config = parse(
        '{"onboarding": {"slides": [{"icon": "music"}]}}',
      );

      expect(
        config.onboarding.slides,
        hasLength(OnboardingConfig.fallback.slides.length),
      );
    });

    test('el archivo decide cuántas láminas hay', () {
      final AppConfig config = parse('''
      {"onboarding": {"slides": [
        {"title": {"es": "1"}}, {"title": {"es": "2"}},
        {"title": {"es": "3"}}, {"title": {"es": "4"}}
      ]}}
      ''');

      expect(config.onboarding.slides, hasLength(4));
    });
  });

  test('las listas que salen del mapper no se pueden modificar', () {
    final AppConfig config = parse('{"filters": {"pinnedCategories": ["A"]}}');

    expect(
      () => config.filters.pinnedCategories.add('B'),
      throwsUnsupportedError,
    );
  });
}
