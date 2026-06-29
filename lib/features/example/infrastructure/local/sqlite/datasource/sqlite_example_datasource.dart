import 'package:eventix/core/services/sqlite/sqlite_service.dart';
import 'package:eventix/features/example/infrastructure/local/local_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';

class SqliteExampleDatasource implements ExampleLocalDatasource {
  final SqliteService _sqliteService;

  SqliteExampleDatasource(this._sqliteService);

  static const String _examplesTable = 'examples';
  static const String _shapesTable = 'shapes';

  @override
  Future<List<LocalExampleModel>> getExamples() async {
    final List<Map<String, dynamic>> rows = await _sqliteService.query(
      _examplesTable,
    );

    return rows.map(LocalExampleModel.fromJson).toList();
  }

  @override
  Future<List<LocalShapeModel>> getShapes() async {
    final List<Map<String, dynamic>> rows = await _sqliteService.query(
      _shapesTable,
    );

    return rows.map(LocalShapeModel.fromJson).toList();
  }

  @override
  Future<void> cacheExample(List<LocalExampleModel> examples) async {
    await _sqliteService.clear(_examplesTable);
    await _sqliteService.insert(
      _examplesTable,
      examples.map((LocalExampleModel m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> clearExampleCache() => _sqliteService.clear(_examplesTable);

  @override
  Future<void> cacheShape(List<LocalShapeModel> shapes) async {
    await _sqliteService.clear(_shapesTable);
    await _sqliteService.insert(
      _shapesTable,
      shapes.map((LocalShapeModel m) => m.toJson()).toList(),
    );
  }

  @override
  Future<void> clearShapeCache() => _sqliteService.clear(_shapesTable);
}