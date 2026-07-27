import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Render estándar de un [AsyncValue]: loader centrado mientras carga,
/// [AsyncErrorView] con reintento en error y `data` con el contenido.
///
/// Evita repetir `when(loading/error/data)` en cada página.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.data,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;

  /// Construye el contenido cuando hay datos.
  final Widget Function(T data) data;

  /// Acción de reintento mostrada en el estado de error.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: UiLoader()),
      error: (Object error, _) => AsyncErrorView(
        message: failureMessage(
          error,
          AppLocalizations.of(context).error_unexpected,
        ),
        onRetry: onRetry,
      ),
      data: data,
    );
  }
}
