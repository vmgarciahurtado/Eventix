import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Estado de carga de pantalla completa: el loader de la marca con una
/// etiqueta en mayúsculas y tracking amplio debajo.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({this.label, super.key});

  /// Tracking de la etiqueta: más aire del habitual porque va en mayúsculas.
  static const double _tracking = 2.4;

  /// Qué se está cargando. Si es null usa la etiqueta genérica.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final String text = label ?? AppLocalizations.of(context).common_loading;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          UiLoader(size: UiSize.large, color: context.colorScheme.primary),
          const SizedBox(height: UiSpacing.large),
          UiText(
            text.toUpperCase(),
            style: UiTextStyle.label,
            align: TextAlign.center,
            color: context.colorScheme.onSurfaceVariant,
            letterSpacing: _tracking,
          ),
        ],
      ),
    );
  }
}
