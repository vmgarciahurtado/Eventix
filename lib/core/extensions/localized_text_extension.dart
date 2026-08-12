import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:flutter/widgets.dart';

extension LocalizedTextX on LocalizedText {
  /// Resuelve el texto contra el idioma activo. El dominio no conoce `Locale`,
  /// así que la traducción del contexto a código de idioma pasa por aquí.
  String of(BuildContext context) =>
      resolve(Localizations.localeOf(context).languageCode);
}
