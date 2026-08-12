import 'package:eventix/core/theme/app_palette.dart';
import 'package:eventix/core/theme/app_theme.dart';
import 'package:eventix/features/app_config/domain/entities/brand_config.dart';
import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BrandConfig brandWith(int primary, int secondary) => BrandConfig(
  tagline: LocalizedText.empty,
  primaryArgb: primary,
  secondaryArgb: secondary,
);

void main() {
  test('los acentos del tema salen de la marca', () {
    final ThemeData theme = AppTheme.from(brandWith(0xFF00FF00, 0xFF0000FF));

    expect(theme.colorScheme.primary, const Color(0xFF00FF00));
    expect(theme.colorScheme.secondary, const Color(0xFF0000FF));
    expect(theme.colorScheme.brightness, Brightness.dark);
  });

  test('las superficies no dependen de la marca', () {
    // El fondo negro es diseño, no parametrización.
    final ThemeData theme = AppTheme.from(brandWith(0xFF00FF00, 0xFF0000FF));

    expect(theme.scaffoldBackgroundColor, AppPalette.background);
    expect(theme.colorScheme.surface, AppPalette.background);
  });

  group('contraste', () {
    test('sobre un acento claro el texto va en negro', () {
      final ThemeData theme = AppTheme.from(brandWith(0xFFF2F04B, 0xFFF2F04B));

      expect(theme.colorScheme.onPrimary, Colors.black);
      expect(theme.colorScheme.onSecondary, Colors.black);
    });

    test('sobre un acento oscuro el texto va en blanco', () {
      // Sin esto, cambiar el amarillo por un morado dejaría los botones
      // ilegibles.
      final ThemeData theme = AppTheme.from(brandWith(0xFF2B0B3A, 0xFF101010));

      expect(theme.colorScheme.onPrimary, Colors.white);
      expect(theme.colorScheme.onSecondary, Colors.white);
    });
  });

  test('el tema por defecto usa la marca de respaldo', () {
    expect(AppTheme.dark.colorScheme.primary, AppPalette.primary);
    expect(AppTheme.dark.colorScheme.secondary, AppPalette.secondary);
  });

  test('la paleta y el respaldo del dominio no se pueden separar', () {
    // El dominio no puede importar Flutter, así que los hex viven dos veces.
    expect(AppPalette.primary.toARGB32(), BrandConfig.fallback.primaryArgb);
    expect(AppPalette.secondary.toARGB32(), BrandConfig.fallback.secondaryArgb);
  });
}
