import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';

abstract interface class EventsRepository {
  Future<Result<List<Event>>> getEvents(EventFilter filter);

  Future<Result<Event>> getEventById(String id);

  Future<Result<List<Category>>> getCategories();

  Future<Result<List<City>>> getCities();
}
