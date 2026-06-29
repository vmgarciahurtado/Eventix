import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';
import 'package:eventix/features/example/domain/repositories/example_repository.dart';
import 'package:eventix/features/example/infrastructure/local/local_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/mappers/local_example_mapper.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';
import 'package:eventix/features/example/infrastructure/remote/http/mappers/remote_example_mapper.dart';
import 'package:eventix/features/example/infrastructure/remote/http/mappers/remote_shape_mapper.dart';
import 'package:eventix/features/example/infrastructure/remote/remote_example_datadource.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleRemoteDatasource _remoteDatasource;
  final ExampleLocalDatasource _localDatasource;

  ExampleRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Result<List<Example>>> getExamples() {
    return executeRepositoryCall(() async {
      final List<LocalExampleModel> cached =
          await _localDatasource.getExamples();
      if (cached.isNotEmpty) return LocalExampleMapper.toEntities(cached);

      final List<Example> examples = RemoteExampleMapper.toEntities(
        await _remoteDatasource.getExamples(),
      );
      await _localDatasource.cacheExample(
        LocalExampleMapper.toModels(examples),
      );
      return examples;
    });
  }

  @override
  Future<Result<List<Shape>>> getShapes() {
    return executeRepositoryCall(() async {
      return RemoteShapeMapper.toEntities(await _remoteDatasource.getShapes());
    });
  }
}
