import 'package:flutter/material.dart';

/// Extension on [BuildContext] that provides convenient access to
/// Material 3 theme data.
///
/// ### Usage example
/// ```dart
/// Widget build(BuildContext context) {
///   return Text(
///     'Hello',
///     style: context.textTheme.bodyLarge,
///   );
/// }
/// ```
extension ThemeContextX on BuildContext {
  /// The resolved [ThemeData] for the nearest [Theme] ancestor.
  ThemeData get theme => Theme.of(this);

  /// Shortcut to [ThemeData.textTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Shortcut to [ThemeData.colorScheme] — primary color access in M3.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns `true` if the current brightness is [Brightness.dark].
  bool get isDark => theme.brightness == Brightness.dark;
}
