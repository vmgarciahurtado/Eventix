import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Success', () {
    test(
      'given a value '
      'when Success is constructed '
      'then data holds that value',
      () {
        const Success<int> result = Success<int>(42);
        expect(result.data, 42);
      },
    );

    test(
      'given a list value '
      'when Success is constructed '
      'then isA<Success> and isNotA<FailureResult>',
      () {
        const Success<List<String>> result = Success<List<String>>(
          <String>['a', 'b'],
        );
        expect(result, isA<Success<List<String>>>());
        expect(result, isNot(isA<FailureResult<List<String>>>()));
      },
    );
  });

  group('FailureResult', () {
    test(
      'given a Failure '
      'when FailureResult is constructed '
      'then failure holds that instance',
      () {
        const FailureResult<int> result = FailureResult<int>(
          ConnectionFailure(),
        );
        expect(result.failure, isA<ConnectionFailure>());
      },
    );

    test(
      'given a Failure '
      'when FailureResult is constructed '
      'then isA<FailureResult> and isNotA<Success>',
      () {
        const FailureResult<int> result = FailureResult<int>(
          ServerFailure(),
        );
        expect(result, isA<FailureResult<int>>());
        expect(result, isNot(isA<Success<int>>()));
      },
    );
  });
}
