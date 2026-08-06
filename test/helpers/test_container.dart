import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Contenedor de pruebas con los reintentos de Riverpod apagados.
ProviderContainer testContainer({
  List<Override> overrides = const <Override>[],
}) => ProviderContainer(
  overrides: overrides,
  retry: (int retryCount, Object error) => null,
);

/// Sostiene el provider, que en Riverpod 3 es autoDispose por defecto.
void keepAlive<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
) => container.listen<T>(
      provider,
      (T? _, T _) {},
      onError: (Object _, StackTrace _) {},
      fireImmediately: true,
    );
