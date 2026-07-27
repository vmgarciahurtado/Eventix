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

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.extraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: UiSpacing.medium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: UiSpacing.large),
              UiButton(
                label: l10n.action_retry,
                variant: UiButtonVariant.outline,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
