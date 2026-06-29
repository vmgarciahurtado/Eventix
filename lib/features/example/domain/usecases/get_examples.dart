import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/domain/repositories/example_repository.dart';

class GetExamples {
  const GetExamples(this._repository);

  final ExampleRepository _repository;

  Future<Result<List<Example>>> call() => _repository.getExamples();
}
