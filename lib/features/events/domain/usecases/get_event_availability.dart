import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';

class GetEventAvailability {
  const GetEventAvailability(this._repository);

  final EventsRepository _repository;

  Future<Result<int>> call(String eventId) =>
      _repository.getAvailableSpots(eventId);
}
