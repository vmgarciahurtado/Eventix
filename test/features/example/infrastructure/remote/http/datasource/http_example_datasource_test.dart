import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/services/http/http_method.dart';
import 'package:eventix/core/services/http/http_service.dart';
import 'package:eventix/features/example/infrastructure/remote/http/datasource/http_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpService extends Mock implements HttpService {}

void main() {
  late MockHttpService mockHttpService;
  late HttpExampleDatasource datasource;

  setUpAll(() {
    registerFallbackValue(HttpMethod.get);
  });

  setUp(() {
    mockHttpService = MockHttpService();
    datasource = HttpExampleDatasource(mockHttpService);
  });

  group('HttpExampleDatasource.getExamples', () {
    test(
      'given a successful http response when getExamples is called '
      'then returns a list of RemoteExampleModels',
      () async {
        when(
          () => mockHttpService.request<Map<String, dynamic>>(
            any(),
            method: any(named: 'method'),
          ),
        ).thenAnswer((_) async => _tExampleResponseJson());

        final List<RemoteExampleModel> result = await datasource.getExamples();

        expect(result, isA<List<RemoteExampleModel>>());
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.name, 'Test Example');
      },
    );

    test(
      'given the http service throws ConnectionFailure '
      'when getExamples is called '
      'then propagates the ConnectionFailure',
      () async {
        when(
          () => mockHttpService.request<Map<String, dynamic>>(
            any(),
            method: any(named: 'method'),
          ),
        ).thenThrow(const ConnectionFailure());

        expect(
          () => datasource.getExamples(),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );
  });

  group('HttpExampleDatasource.getShapes', () {
    test(
      'given a successful http response when getShapes is called '
      'then returns a list of RemoteShapeModels',
      () async {
        when(
          () => mockHttpService.request<Map<String, dynamic>>(
            any(),
            method: any(named: 'method'),
          ),
        ).thenAnswer((_) async => _tShapeResponseJson());

        final List<RemoteShapeModel> result = await datasource.getShapes();

        expect(result, isA<List<RemoteShapeModel>>());
        expect(result.length, 1);
        expect(result.first.id, 2);
        expect(result.first.name, 'Circle');
      },
    );

    test(
      'given the http service throws ServerFailure when getShapes is called '
      'then propagates the ServerFailure',
      () async {
        when(
          () => mockHttpService.request<Map<String, dynamic>>(
            any(),
            method: any(named: 'method'),
          ),
        ).thenThrow(const ServerFailure());

        expect(
          () => datasource.getShapes(),
          throwsA(isA<ServerFailure>()),
        );
      },
    );
  });
}

Map<String, dynamic> _tExampleResponseJson() => <String, dynamic>{
  'results': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 1,
      'name': 'Test Example',
      'description': 'Test description',
    },
  ],
};

Map<String, dynamic> _tShapeResponseJson() => <String, dynamic>{
  'results': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 2,
      'name': 'Circle',
      'description': 'A round shape',
    },
  ],
};
