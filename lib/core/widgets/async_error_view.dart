import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Mensaje amigable a partir de un error capturado por Riverpod (`AsyncError`).
///
/// [fallback] se usa cuando el error no es un [Failure]; pásalo localizado
/// (ej. `AppLocalizations.of(context).error_unexpected`).
String failureMessage(Object error, String fallback) =>
    error is Failure ? error.userMessage : fallback;

/// Vista de error con opción de reintentar, para estados `AsyncError`.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({required this.message, this.onRetry, super.key});

  static const double _ringSize = 112;
  static const double _ringTint = 0.12;

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color accent = context.statusColors.warning;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UiSpacing.extraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: _ringSize,
              height: _ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: _ringTint),
                border: Border.all(color: accent),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: UiIconSize.extraLarge,
                color: accent,
              ),
            ),
            const SizedBox(height: UiSpacing.large),
            Text(
              l10n.error_title.toUpperCase(),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: UiSpacing.small),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: UiSpacing.extraLarge),
              UiButton(
                label: l10n.action_retry,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
