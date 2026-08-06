import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Un `SupabaseClient` real apuntando a un transporte falso.
class FakeSupabase {
  FakeSupabase(this._respond) {
    client = SupabaseClient(
      'https://proyecto.supabase.test',
      'clave-publica-de-prueba',
      authOptions: AuthClientOptions(pkceAsyncStorage: _MemoryStorage()),
      httpClient: MockClient((http.Request request) async {
        requests.add(request);
        final http.Response response = _respond(request);
        return http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: request,
        );
      }),
    );
  }

  /// Responde con la misma carga a cualquier petición.
  factory FakeSupabase.replying(Object? body, {int status = 200}) =>
      FakeSupabase((http.Request _) => jsonResponse(body, status: status));

  /// Falla toda petición, para ejercitar la traducción de errores.
  factory FakeSupabase.failing({
    int status = 500,
    String message = 'boom',
  }) => FakeSupabase(
    (http.Request _) => jsonResponse(
      <String, dynamic>{'message': message, 'code': '$status'},
      status: status,
    ),
  );

  final http.Response Function(http.Request request) _respond;

  final List<http.Request> requests = <http.Request>[];

  late final SupabaseClient client;

  http.Request get lastRequest => requests.last;

  Uri get lastUri => lastRequest.url;

  Map<String, String> get lastQuery => lastUri.queryParameters;

  Map<String, dynamic> get lastBody =>
      jsonDecode(lastRequest.body) as Map<String, dynamic>;

  void dispose() => client.dispose();
}

class _MemoryStorage extends GotrueAsyncStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _values[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _values.remove(key);
}

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
  jsonEncode(body),
  status,
  headers: <String, String>{'content-type': 'application/json'},
);
