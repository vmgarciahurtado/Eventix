import 'package:eventix/core/services/http/http_method.dart';

abstract interface class HttpService {
  Future<T> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  });
}
