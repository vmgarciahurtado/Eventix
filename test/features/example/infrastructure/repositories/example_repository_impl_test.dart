import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/infrastructure/local/local_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';
import 'package:eventix/features/example/infrastructure/remote/remote_example_datadource.dart';
import 'package:eventix/features/example/infrastructure/repositories/example_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDatasource extends Mock implements ExampleRemoteDatasource {}

class MockLocalDatasource extends Mock implements ExampleLocalDatasource {}

void main() {
  late MockRemoteDatasource mockRemote;
  late MockLocalDatasource mockLocal;
  late ExampleRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<LocalExampleModel>[]);
  });

  setUp(() {
    mockRemote = MockRemoteDatasource();
    mockLocal = MockLocalDatasource();
    repository = ExampleRepositoryImpl(mockRemote, mockLocal);
  });

  group('ExampleRepositoryImpl.getExamples', () {
    test(
      'given a non-empty local cache when getExamples is called '
      'then returns mapped entities without calling remote',
      () async {
        when(
          () => mockLocal.getExamples(),
        ).thenAnswer((_) async => <LocalExampleModel>[_tLocalExample()]);

        final Result<List<Example>> result = await repository.getExamples();

        expect(result, isA<Success<List<Example>>>());
        final List<Example> examples =
            (result as Success<List<Example>>).data;
        expect(examples.length, 1);
        expect(examples.first.id, 1);
        verifyNever(() => mockRemote.getExamples());
      },
    );

    test(
      'given an empty local cache when getExamples is called '
      'then fetches from remote, caches the result and returns Success',
      () async {
        when(
          () => mockLocal.getExamples(),
        ).thenAnswer((_) async => <LocalExampleModel>[]);
        when(
          () => mockRemote.getExamples(),
        ).thenAnswer((_) async => <RemoteExampleModel>[_tRemoteExample()]);
        when(
          () => mockLocal.cacheExample(any()),
        ).thenAnswer((_) async {});

        final Result<List<Example>> result = await repository.getExamples();

        expect(result, isA<Success<List<Example>>>());
        verify(() => mockRemote.getExamples()).called(1);
        verify(() => mockLocal.cacheExample(any())).called(1);
      },
    );

    test(
      'given an empty local cache and remote throws ConnectionFailure '
      'when getExamples is called '
      'then returns FailureResult with ConnectionFailure',
      () async {
        when(
          () => mockLocal.getExamples(),
        ).thenAnswer((_) async => <LocalExampleModel>[]);
        when(
          () => mockRemote.getExamples(),
        ).thenThrow(const ConnectionFailure());

        final Result<List<Example>> result = await repository.getExamples();

        expect(result, isA<FailureResult<List<Example>>>());
        final Failure failure =
            (result as FailureResult<List<Example>>).failure;
        expect(failure, isA<ConnectionFailure>());
      },
    );
  });

  group('ExampleRepositoryImpl.getShapes', () {
    test(
      'given a successful remote response when getShapes is called '
      'then returns Success with the mapped shape entities',
      () async {
        when(
          () => mockRemote.getShapes(),
        ).thenAnswer((_) async => <RemoteShapeModel>[_tRemoteShape()]);

        final Result<List<Shape>> result = await repository.getShapes();

        expect(result, isA<Success<List<Shape>>>());
        final List<Shape> shapes = (result as Success<List<Shape>>).data;
        expect(shapes.length, 1);
        expect(shapes.first.id, 2);
      },
    );

    test(
      'given the remote throws ServerFailure when getShapes is called '
      'then returns FailureResult with ServerFailure',
      () async {
        when(
          () => mockRemote.getShapes(),
        ).thenThrow(const ServerFailure());

        final Result<List<Shape>> result = await repository.getShapes();

        expect(result, isA<FailureResult<List<Shape>>>());
        final Failure failure = (result as FailureResult<List<Shape>>).failure;
        expect(failure, isA<ServerFailure>());
      },
    );
  });
}

LocalExampleModel _tLocalExample() => const LocalExampleModel(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);

RemoteExampleModel _tRemoteExample() => const RemoteExampleModel(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);

RemoteShapeModel _tRemoteShape() => const RemoteShapeModel(
  id: 2,
  name: 'Circle',
  description: 'A round shape',
);
