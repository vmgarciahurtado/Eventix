import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/constants/fonts.dart';
import 'package:eventix/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

/// Tema de Eventix: parte del `UiKitTheme` oscuro y le impone la identidad de
/// la marca.
abstract final class AppTheme {
  static ThemeData get dark {
    final ThemeData base = UiKitTheme.dark(
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
      fontFamily: Fonts.poppins,
      headingFontFamily: Fonts.poppins,
      statusColors: const UiStatusColors(
        success: AppPalette.success,
        warning: AppPalette.warning,
        info: AppPalette.secondary,
      ),
    );

    final ColorScheme scheme = base.colorScheme.copyWith(
      primary: AppPalette.primary,
      onPrimary: Colors.black,
      secondary: AppPalette.secondary,
      onSecondary: Colors.black,
      surface: AppPalette.background,
      onSurface: Colors.white,
      surfaceContainerLowest: AppPalette.background,
      surfaceContainerLow: AppPalette.surface,
      surfaceContainer: AppPalette.surface,
      surfaceContainerHigh: AppPalette.surfaceRaised,
      surfaceContainerHighest: AppPalette.surfaceRaised,
      onSurfaceVariant: const Color(0xFFA89BA0),
      outline: AppPalette.outline,
      outlineVariant: AppPalette.outline,
      error: AppPalette.danger,
      onError: Colors.black,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.background,
      canvasColor: AppPalette.background,
      dividerColor: AppPalette.outline,
      textTheme: _display(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppPalette.surfaceRaised,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: UiRadius.borderMedium),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UiRadius.large),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AppPalette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: UiRadius.borderLarge,
          side: BorderSide(color: AppPalette.outline),
        ),
      ),
    );
  }

  /// Titulares condensados en mayúsculas. El tracking negativo compacta las
  /// palabras para imitar una display condensada sin cargar otra fuente.
  static TextTheme _display(TextTheme base) {
    TextStyle? heading(TextStyle? style) => style?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.8,
      height: 1.05,
      color: Colors.white,
    );
    return base.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}
