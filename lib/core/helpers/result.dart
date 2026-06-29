import 'package:eventix/core/errors/failure.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}

extension ResultX<T> on Result<T> {
  /// Devuelve el valor de [Success] o lanza el [Failure] contenido.
  ///
  /// Útil en `FutureProvider`/`AsyncNotifier`: al relanzar el [Failure],
  /// Riverpod lo expone como `AsyncError` y la UI lo lee con `.when(error:)`.
  T getOrThrow() => switch (this) {
    Success<T>(data: final T data) => data,
    FailureResult<T>(failure: final Failure failure) => throw failure,
  };
}
