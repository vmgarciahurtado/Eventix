import 'package:dio/dio.dart';
import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/services/http/dio/interceptors/logging_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = Dio();
  dio.options.baseUrl = Env.baseUrl;
  dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
  dio.options.contentType = 'application/json';
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 5);
  dio.interceptors.add(LoggingInterceptor());
  return dio;
});
