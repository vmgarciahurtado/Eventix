import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

/// Controls the [ThemeMode] of the entire app.
/// By default, it follows the operating system theme.
// To change it from any widget:
/// ```dart
/// ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
// ```
final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
