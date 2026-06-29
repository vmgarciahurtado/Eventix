import 'package:flutter/material.dart';
import 'package:eventix/core/constants/fonts.dart';
import 'package:eventix/core/theme/app_colors.dart';
import 'package:eventix/core/theme/app_radius.dart';
import 'package:eventix/core/theme/app_spacing.dart';

abstract final class AppTheme {
  static final ThemeData light = _buildTheme(brightness: Brightness.light);
  static final ThemeData dark = _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
      borderRadius: AppRadius.md,
    );
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: Fonts.poppins,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
        ),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),

      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.full),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor:
              WidgetStatePropertyAll<Color>(colorScheme.surfaceContainer),
          surfaceTintColor:
              const WidgetStatePropertyAll<Color>(Colors.transparent),
          elevation: const WidgetStatePropertyAll<double>(6),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: AppRadius.md),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xs,
            ),
          ),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: MenuItemButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  /// Aplica una fuente de titulares a los slots display, headline y titleLarge,
  /// dejando el resto con la fuente base del tema.
  ///
  /// Úsalo cuando el proyecto necesite dos fuentes distintas:
  /// ```dart
  /// theme: AppTheme.light.copyWith(
  ///   textTheme: AppTheme.withHeadingFont(
  ///     AppTheme.light.textTheme, 'Merriweather',
  ///   ),
  /// ),
  /// ```
  static TextTheme withHeadingFont(TextTheme base, String fontFamily) {
    TextStyle? apply(TextStyle? style) =>
        style?.copyWith(fontFamily: fontFamily);
    return base.copyWith(
      displayLarge: apply(base.displayLarge),
      displayMedium: apply(base.displayMedium),
      displaySmall: apply(base.displaySmall),
      headlineLarge: apply(base.headlineLarge),
      headlineMedium: apply(base.headlineMedium),
      headlineSmall: apply(base.headlineSmall),
      titleLarge: apply(base.titleLarge),
    );
  }
}
