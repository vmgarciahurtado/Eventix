import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';

class GetCitiesUseCase {
  const GetCitiesUseCase(this._repository);

  final EventsRepository _repository;

  Future<Result<List<City>>> call() => _repository.getCities();
}
