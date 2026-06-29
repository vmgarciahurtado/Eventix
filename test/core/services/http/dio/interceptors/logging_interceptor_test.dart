import 'package:dio/dio.dart';
import 'package:eventix/core/services/http/dio/interceptors/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late LoggingInterceptor interceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockResponseInterceptorHandler mockResponseHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions()),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions()),
    );
  });

  setUp(() {
    interceptor = LoggingInterceptor();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockResponseHandler = MockResponseInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
  });

  group('LoggingInterceptor.onRequest', () {
    test(
      'given a request without body '
      'when onRequest is called '
      'then handler.next is called once with the options',
      () {
        final RequestOptions options = RequestOptions(path: '/test');

        interceptor.onRequest(options, mockRequestHandler);

        verify(() => mockRequestHandler.next(options)).called(1);
      },
    );

    test(
      'given a request with body data '
      'when onRequest is called '
      'then handler.next is called once with the options',
      () {
        final RequestOptions options = RequestOptions(
          path: '/test',
          data: <String, dynamic>{'key': 'value'},
        );

        interceptor.onRequest(options, mockRequestHandler);

        verify(() => mockRequestHandler.next(options)).called(1);
      },
    );
  });

  group('LoggingInterceptor.onResponse', () {
    test(
      'given a successful response '
      'when onResponse is called '
      'then handler.next is called once with the response',
      () {
        final Response<dynamic> response = Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
          data: <String, dynamic>{'id': 1},
        );

        interceptor.onResponse(response, mockResponseHandler);

        verify(() => mockResponseHandler.next(response)).called(1);
      },
    );
  });

  group('LoggingInterceptor.onError', () {
    test(
      'given an error without response data '
      'when onError is called '
      'then handler.next is called once with the error',
      () {
        final DioException error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        interceptor.onError(error, mockErrorHandler);

        verify(() => mockErrorHandler.next(error)).called(1);
      },
    );

    test(
      'given an error with response data '
      'when onError is called '
      'then handler.next is called once with the error',
      () {
        final DioException error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
            data: <String, dynamic>{'message': 'internal error'},
          ),
          type: DioExceptionType.badResponse,
        );

        interceptor.onError(error, mockErrorHandler);

        verify(() => mockErrorHandler.next(error)).called(1);
      },
    );
  });
}
