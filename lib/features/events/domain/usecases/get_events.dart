import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';

class GetEvents {
  const GetEvents(this._repository);

  final EventsRepository _repository;

  Future<Result<List<Event>>> call(EventFilter filter) =>
      _repository.getEvents(filter);
}
