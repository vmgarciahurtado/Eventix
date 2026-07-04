import 'dart:developer' as developer;

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';

Future<Result<T>> executeRepositoryCall<T>(Future<T> Function() call) async {
  try {
    final T data = await call();
    return Success<T>(data);
  } on Failure catch (e) {
    return FailureResult<T>(e);
  } catch (e, st) {
    // El detalle técnico va al log (no a la UI): UnexpectedFailure muestra
    // siempre un mensaje genérico al usuario.
    developer.log(
      'Error inesperado en repositorio',
      name: 'executeRepositoryCall',
      error: e,
      stackTrace: st,
    );
    return FailureResult<T>(UnexpectedFailure(e.toString()));
  }
}
