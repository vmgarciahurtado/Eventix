import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/entities/shape.dart';

abstract interface class ExampleRepository {
  Future<Result<List<Example>>> getExamples();
  Future<Result<List<Shape>>> getShapes();
}
