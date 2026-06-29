import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final EventsRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getCategories();
}
