import 'package:eventix/core/theme/app_icons.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todo el catálogo tiene icono', () {
    for (final AppIcon icon in AppIcon.values) {
      expect(AppIcons.of(icon), isA<IconData>(), reason: icon.name);
    }
  });

  test('no hay dos nombres apuntando al mismo dibujo', () {
    // Dos alias tendrían el mismo efecto y sobraría uno.
    final Set<IconData> icons = AppIcon.values.map(AppIcons.of).toSet();

    expect(icons, hasLength(AppIcon.values.length));
  });

  test('los iconos son constantes del paquete, no code points sueltos', () {
    // Construirlos desde el JSON obligaría a desactivar el tree shaking.
    expect(AppIcons.of(AppIcon.explore), Icons.explore_outlined);
    expect(AppIcons.of(AppIcon.ticket), Icons.confirmation_num_outlined);
  });
}
