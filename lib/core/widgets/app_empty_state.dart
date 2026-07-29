import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/widgets/app_character.dart';
import 'package:flutter/material.dart';

/// Estado vacío de Eventix: la mascota en vez de un ícono, y el título con la
/// última palabra en amarillo, como en el diseño.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  static const double _characterHeight = 180;

  final String title;
  final String message;

  /// Acción opcional debajo del mensaje, típicamente un `UiButton`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final Widget? action = this.action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UiSpacing.extraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppCharacter(height: _characterHeight),
            const SizedBox(height: UiSpacing.large),
            _HighlightedTitle(title: title),
            const SizedBox(height: UiSpacing.small),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: UiSpacing.extraLarge),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

/// Título en mayúsculas con la última palabra en el amarillo de marca. Es el
/// recurso tipográfico del diseño y se resuelve aquí para no repetirlo.
class _HighlightedTitle extends StatelessWidget {
  const _HighlightedTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final List<String> words = title.toUpperCase().trim().split(' ');
    final String last = words.removeLast();
    final String head = words.join(' ');
    final TextStyle? style = context.textTheme.headlineSmall;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (head.isNotEmpty) TextSpan(text: '$head '),
          TextSpan(
            text: last,
            style: TextStyle(color: context.colorScheme.primary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
