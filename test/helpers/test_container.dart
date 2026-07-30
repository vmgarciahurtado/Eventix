import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Contenedor de pruebas con los reintentos apagados.
///
/// Riverpod 3 reintenta por defecto todo lo que no sea un `Error`, y nuestros
/// `Failure` son `Exception`: un provider que falla se queda reintentando con
/// backoff (10 intentos, ~38 s) en vez de emitir el error. Una prueba de mapeo
/// no debe esperar ese ciclo; el comportamiento del reintento se prueba aparte.
ProviderContainer testContainer({
  List<Override> overrides = const <Override>[],
}) => ProviderContainer(
  overrides: overrides,
  retry: (int retryCount, Object error) => null,
);

/// En Riverpod 3 todo provider es autoDispose por defecto: sin un oyente se
/// recicla antes de que la prueba alcance a leer el resultado. El `onError`
/// vacío evita que un provider que falla tire el error a la zona y mate la
/// prueba antes de poder afirmar nada sobre él.
void keepAlive<T>(
  ProviderContainer container,
  ProviderListenable<T> provider,
) => container.listen<T>(
      provider,
      (T? _, T _) {},
      onError: (Object _, StackTrace _) {},
      fireImmediately: true,
    );
