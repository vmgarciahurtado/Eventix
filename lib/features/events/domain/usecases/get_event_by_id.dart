import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';

class GetEventById {
  const GetEventById(this._repository);

  final EventsRepository _repository;

  Future<Result<Event>> call(String id) => _repository.getEventById(id);
}
