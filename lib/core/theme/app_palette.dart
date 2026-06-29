import 'package:flutter/material.dart';

/// Colores de marca de Eventix. Se inyectan en `UiKitTheme` para generar el
/// `ThemeData` (Material 3) del que toman color todos los componentes del
/// design system (`app_ui_kit`).
abstract final class AppPalette {
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF0EA5A4);
}
