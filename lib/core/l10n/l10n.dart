/// This file allows changing the localization implementation in a single place,
/// avoiding broken import problems when Flutter updates the file generation.
///
/// Usage:
/// ```dart
/// import 'package:base_path/l10n/l10n.dart';
///
/// In your widget:
/// final strings = AppLocalizations.of(context);
/// ```
library;

// Export types from Flutter
export 'package:flutter/material.dart' show Locale;
// Export delegates from Flutter for localization
export 'package:flutter_localizations/flutter_localizations.dart';

// Export AppLocalizations from the local location
export 'app_localizations.dart';
