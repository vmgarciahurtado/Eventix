import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ REQUEST');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> resp, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ RESPONSE');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint(
        '│ ${resp.requestOptions.method} ${resp.requestOptions.uri}',
      );
      debugPrint('│ Status: ${resp.statusCode}');
      debugPrint('│ Data: ${resp.data}');
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(resp);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ ERROR');
      debugPrint('├─────────────────────────────────────────────────');
      debugPrint('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('│ Status: ${err.response?.statusCode}');
      debugPrint('│ Error: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
