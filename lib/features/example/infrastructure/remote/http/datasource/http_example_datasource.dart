import 'package:eventix/core/services/http/http_method.dart';
import 'package:eventix/core/services/http/http_service.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_response.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_response.dart';
import 'package:eventix/features/example/infrastructure/remote/remote_example_datadource.dart';

class HttpExampleDatasource implements ExampleRemoteDatasource {
  final HttpService _httpService;

  HttpExampleDatasource(this._httpService);

  @override
  Future<List<RemoteExampleModel>> getExamples() async {
    final Map<String, dynamic> response = await _httpService
        .request<Map<String, dynamic>>(
          '/examples',
          method: HttpMethod.get,
        );

    return RemoteExampleResponse.fromJson(response).results;
  }

  @override
  Future<List<RemoteShapeModel>> getShapes() async {
    final Map<String, dynamic> response = await _httpService
        .request<Map<String, dynamic>>(
          '/shapes',
          method: HttpMethod.post,
        );

    return RemoteShapeResponse.fromJson(response).results;
  }
}
