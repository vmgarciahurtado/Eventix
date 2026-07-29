import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Render estándar de un [AsyncValue]: [AppLoadingView] mientras carga,
/// [AsyncErrorView] con reintento en error y `data` con el contenido.
///
/// Evita repetir `when(loading/error/data)` en cada página.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingLabel,
    super.key,
  });

  final AsyncValue<T> value;

  /// Construye el contenido cuando hay datos.
  final Widget Function(T data) data;

  /// Acción de reintento mostrada en el estado de error.
  final VoidCallback? onRetry;

  /// Qué se está cargando, para la etiqueta del loader.
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => AppLoadingView(label: loadingLabel),
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
