import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';

abstract interface class ExampleRemoteDatasource {
  Future<List<RemoteExampleModel>> getExamples();
  Future<List<RemoteShapeModel>> getShapes();
}
