import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';

Future<Result<T>> executeRepositoryCall<T>(Future<T> Function() call) async {
  try {
    final T data = await call();
    return Success<T>(data);
  } on Failure catch (e) {
    return FailureResult<T>(e);
  } catch (e) {
    return FailureResult<T>(UnexpectedFailure(e.toString()));
  }
}
