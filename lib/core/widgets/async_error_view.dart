import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:flutter/material.dart';

/// Mensaje amigable a partir de un error capturado por Riverpod (`AsyncError`).
String failureMessage(Object error) =>
    error is Failure ? error.userMessage : 'Ocurrió un error inesperado';

/// Vista de error con opción de reintentar, para estados `AsyncError`.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: UiSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: UiSpacing.lg),
              UiButton(
                label: 'Reintentar',
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
