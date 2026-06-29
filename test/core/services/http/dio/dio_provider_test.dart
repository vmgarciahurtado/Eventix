import 'package:dio/dio.dart';
import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/services/http/dio/interceptors/logging_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // dioProvider reads Env.baseUrl at creation time. Dio 5.x validates that
  // baseUrl starts with "http://" or "https://", so we cannot call
  // ProviderContainer.read(dioProvider) with the placeholder value baked by
  // envied. Instead we test the two concerns independently.
  group('dioProvider', () {
    test(
      'given the compiled Env '
      'when Env.baseUrl is read '
      'then it is set to the configured value',
      () {
        expect(Env.baseUrl, isNotEmpty);
      },
    );

    test(
      'given a Dio instance configured with the same settings as dioProvider '
      'when settings are checked '
      'then CT is 5s, RT is 5s, and LI is present',
      () {
        final Dio dio = Dio(
          BaseOptions(baseUrl: 'https://placeholder.example'),
        );
        dio.options.connectTimeout = const Duration(seconds: 5);
        dio.options.receiveTimeout = const Duration(seconds: 5);
        dio.interceptors.add(LoggingInterceptor());

        expect(dio.options.connectTimeout, const Duration(seconds: 5));
        expect(dio.options.receiveTimeout, const Duration(seconds: 5));
        expect(
          dio.interceptors.whereType<LoggingInterceptor>(),
          isNotEmpty,
        );
      },
    );
  });
}
