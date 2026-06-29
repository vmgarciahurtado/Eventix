import 'package:dio/dio.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/services/http/dio/dio_http_service.dart';
import 'package:eventix/core/services/http/http_method.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DioHttpService service;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    mockDio = MockDio();
    service = DioHttpService(mockDio);
  });

  void givenDioReturns(dynamic responseData) {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        data: responseData,
        statusCode: 200,
      ),
    );
  }

  void givenDioThrows(Object error) {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenThrow(error);
  }

  DioException dioErrorWithType(DioExceptionType type) => DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
  );

  DioException dioErrorWithStatusCode(int statusCode) => DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
    ),
    type: DioExceptionType.badResponse,
  );

  DioException dioErrorWithNoResponse() => DioException(
    requestOptions: RequestOptions(path: '/test'),
  );

  group('DioHttpService.request', () {
    test(
      'given a successful Dio response '
      'when request is called '
      'then returns the response data',
      () async {
        givenDioReturns(<String, dynamic>{'id': 1});

        final dynamic result = await service.request<dynamic>(
          '/test',
          method: HttpMethod.get,
        );

        expect(result, <String, dynamic>{'id': 1});
      },
    );

    test(
      'given a DioException with connectionTimeout '
      'when request is called '
      'then throws ConnectionFailure',
      () async {
        givenDioThrows(dioErrorWithType(DioExceptionType.connectionTimeout));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );

    test(
      'given a DioException with sendTimeout '
      'when request is called '
      'then throws ConnectionFailure',
      () async {
        givenDioThrows(dioErrorWithType(DioExceptionType.sendTimeout));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );

    test(
      'given a DioException with receiveTimeout '
      'when request is called '
      'then throws ConnectionFailure',
      () async {
        givenDioThrows(dioErrorWithType(DioExceptionType.receiveTimeout));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );

    test(
      'given a DioException with connectionError '
      'when request is called '
      'then throws ConnectionFailure',
      () async {
        givenDioThrows(dioErrorWithType(DioExceptionType.connectionError));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<ConnectionFailure>()),
        );
      },
    );

    test(
      'given a DioException with no response (null statusCode) '
      'when request is called '
      'then throws UnexpectedFailure',
      () async {
        givenDioThrows(dioErrorWithNoResponse());

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<UnexpectedFailure>()),
        );
      },
    );

    test(
      'given a DioException with status 401 '
      'when request is called '
      'then throws UnauthorizedFailure',
      () async {
        givenDioThrows(dioErrorWithStatusCode(401));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<UnauthorizedFailure>()),
        );
      },
    );

    test(
      'given a DioException with status 404 '
      'when request is called '
      'then throws NotFoundFailure',
      () async {
        givenDioThrows(dioErrorWithStatusCode(404));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<NotFoundFailure>()),
        );
      },
    );

    test(
      'given a DioException with status 500 '
      'when request is called '
      'then throws ServerFailure with the status code in the message',
      () async {
        givenDioThrows(dioErrorWithStatusCode(500));

        await expectLater(
          service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(
            isA<ServerFailure>().having(
              (ServerFailure f) => f.userMessage,
              'userMessage',
              contains('500'),
            ),
          ),
        );
      },
    );

    test(
      'given a non-DioException error '
      'when request is called '
      'then throws UnexpectedFailure',
      () async {
        givenDioThrows(Exception('network error'));

        expect(
          () async => service.request<dynamic>('/test', method: HttpMethod.get),
          throwsA(isA<UnexpectedFailure>()),
        );
      },
    );
  });
}
