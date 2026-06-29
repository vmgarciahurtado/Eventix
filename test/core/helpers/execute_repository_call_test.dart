import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('executeRepositoryCall', () {
    test(
      'given a call that returns a value '
      'when executeRepositoryCall is invoked '
      'then returns Success with that value',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => 42,
        );
        expect(result, isA<Success<int>>());
        expect((result as Success<int>).data, 42);
      },
    );

    test(
      'given a call that throws ConnectionFailure '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with ConnectionFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw const ConnectionFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect(
          (result as FailureResult<int>).failure,
          isA<ConnectionFailure>(),
        );
      },
    );

    test(
      'given a call that throws ServerFailure '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with ServerFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw const ServerFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect((result as FailureResult<int>).failure, isA<ServerFailure>());
      },
    );

    test(
      'given a call that throws NotFoundFailure '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with NotFoundFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw const NotFoundFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect((result as FailureResult<int>).failure, isA<NotFoundFailure>());
      },
    );

    test(
      'given a call that throws UnauthorizedFailure '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with UnauthorizedFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw const UnauthorizedFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect(
          (result as FailureResult<int>).failure,
          isA<UnauthorizedFailure>(),
        );
      },
    );

    test(
      'given a call that throws UnexpectedFailure '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with UnexpectedFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw const UnexpectedFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect(
          (result as FailureResult<int>).failure,
          isA<UnexpectedFailure>(),
        );
      },
    );

    test(
      'given a call that throws a generic Exception '
      'when executeRepositoryCall is invoked '
      'then returns FailureResult with UnexpectedFailure',
      () async {
        final Result<int> result = await executeRepositoryCall<int>(
          () async => throw Exception('something went wrong'),
        );
        expect(result, isA<FailureResult<int>>());
        final Failure failure = (result as FailureResult<int>).failure;
        expect(failure, isA<UnexpectedFailure>());
        expect(failure.userMessage, contains('something went wrong'));
      },
    );
  });
}
