import 'package:flutter/material.dart';

/// Colores de marca de Eventix, tomados del icono de la app: amarillo neón y
/// magenta sobre negro. Se inyectan en `UiKitTheme` y se completan en
/// [AppTheme], que fija las superficies oscuras porque Material 3 no las
/// deriva bien a partir de un amarillo saturado.
abstract final class AppPalette {
  /// Acento principal: el amarillo del logo. Es el respaldo de
  /// `brand.primaryColor` del JSON, que es quien manda en tiempo de ejecución.
  static const Color primary = Color(0xFFF2F04B);

  /// Acento secundario: el magenta del degradado del icono. Respaldo de
  /// `brand.secondaryColor`.
  static const Color secondary = Color(0xFFE64BC8);

  /// Fondo de la app. Negro con un punto de calidez para que no se vea plano.
  static const Color background = Color(0xFF0B0709);

  /// Fondo de tarjetas y campos, un paso por encima del fondo.
  static const Color surface = Color(0xFF171214);

  /// Fondo de elementos elevados (hojas, menús, chips sin seleccionar).
  static const Color surfaceRaised = Color(0xFF241C1F);

  /// Bordes y separadores: apenas visibles, para no romper el negro.
  static const Color outline = Color(0xFF3A2F33);

  /// Confirmado / éxito: el verde neón de la referencia.
  static const Color success = Color(0xFF6BF29B);

  /// Pendiente / atención: el naranja de la referencia.
  static const Color warning = Color(0xFFF2793D);

  /// Error y estados destructivos.
  static const Color danger = Color(0xFFFF5A5A);
}
