import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/domain/repositories/example_repository.dart';
import 'package:eventix/features/example/domain/usecases/get_examples.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExampleRepository extends Mock implements ExampleRepository {}

void main() {
  late MockExampleRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(<Example>[]);
    registerFallbackValue(<Shape>[]);
  });

  setUp(() {
    mockRepository = MockExampleRepository();
  });

  group('GetExamples', () {
    test(
      'given a repository returning examples '
      'when called '
      'then returns Success and delegates to repository once',
      () async {
        when(
          () => mockRepository.getExamples(),
        ).thenAnswer(
          (_) async => Success<List<Example>>(<Example>[_tExample()]),
        );
        final GetExamples useCase = GetExamples(mockRepository);

        final Result<List<Example>> result = await useCase.call();

        expect(result, isA<Success<List<Example>>>());
        verify(() => mockRepository.getExamples()).called(1);
      },
    );

    test(
      'given a repository returning a failure '
      'when called '
      'then returns FailureResult and delegates to repository once',
      () async {
        when(
          () => mockRepository.getExamples(),
        ).thenAnswer(
          (_) async =>
              const FailureResult<List<Example>>(ConnectionFailure()),
        );
        final GetExamples useCase = GetExamples(mockRepository);

        final Result<List<Example>> result = await useCase.call();

        expect(result, isA<FailureResult<List<Example>>>());
        verify(() => mockRepository.getExamples()).called(1);
      },
    );
  });
}

Example _tExample() => const Example(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);
