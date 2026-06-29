import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';

abstract interface class ExampleLocalDatasource {
  Future<List<LocalExampleModel>> getExamples();
  Future<List<LocalShapeModel>> getShapes();

  Future<void> cacheExample(List<LocalExampleModel> examples);
  Future<void> clearExampleCache();

  Future<void> cacheShape(List<LocalShapeModel> shapes);
  Future<void> clearShapeCache();
}
