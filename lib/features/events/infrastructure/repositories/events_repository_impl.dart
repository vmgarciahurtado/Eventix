import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/mappers/event_mappers.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';

class EventsRepositoryImpl implements EventsRepository {
  const EventsRepositoryImpl(this._datasource);

  final EventsDatasource _datasource;

  @override
  Future<Result<List<Event>>> getEvents(EventFilter filter) =>
      executeRepositoryCall(() async {
        final List<RemoteEventModel> models = await _datasource.fetchEvents(
          filter,
        );
        return models.map(EventMapper.toEntity).toList();
      });

  @override
  Future<Result<Event>> getEventById(String id) =>
      executeRepositoryCall(() async {
        final RemoteEventModel model = await _datasource.fetchEventById(id);
        return EventMapper.toEntity(model);
      });

  @override
  Future<Result<List<Category>>> getCategories() =>
      executeRepositoryCall(() async {
        final List<RemoteCategoryModel> models = await _datasource
            .fetchCategories();
        return models.map(CategoryMapper.toEntity).toList();
      });

  @override
  Future<Result<List<City>>> getCities() => executeRepositoryCall(() async {
    final List<RemoteCityModel> models = await _datasource.fetchCities();
    return models.map(CityMapper.toEntity).toList();
  });
}
