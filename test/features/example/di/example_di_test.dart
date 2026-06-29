import 'package:dio/dio.dart';
import 'package:eventix/core/services/http/dio/dio_provider.dart';
import 'package:eventix/features/example/di/example_di.dart';
import 'package:eventix/features/example/domain/repositories/example_repository.dart';
import 'package:eventix/features/example/domain/usecases/get_examples.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        // dioProvider requires a valid URL from .env, which may not be set in
        // the test environment. We override it with a minimal Dio instance so
        // the rest of the provider graph can resolve normally.
        dioProvider.overrideWithValue(
          Dio()..options.baseUrl = 'https://test.example.com',
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('example DI providers', () {
    test(
      'given the provider graph '
      'when exampleRepositoryProvider is read '
      'then returns an ExampleRepository instance',
      () {
        expect(
          container.read(exampleRepositoryProvider),
          isA<ExampleRepository>(),
        );
      },
    );

    test(
      'given the provider graph '
      'when getExamplesProvider is read '
      'then returns a GetExamples instance',
      () {
        expect(container.read(getExamplesProvider), isA<GetExamples>());
      },
    );
  });
}
