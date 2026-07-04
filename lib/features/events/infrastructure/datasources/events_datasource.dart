import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';

/// Contrato del datasource de eventos. La implementación concreta usa Supabase
/// y traduce sus errores a `Failure`.
abstract interface class EventsDatasource {
  Future<List<RemoteEventModel>> fetchEvents(EventFilter filter);

  Future<RemoteEventModel> fetchEventById(String id);

  Future<List<RemoteCategoryModel>> fetchCategories();

  Future<List<RemoteCityModel>> fetchCities();

  /// Cupos disponibles del evento (capacidad menos reservas activas),
  /// calculados por el backend (vista `event_availability`).
  Future<int> fetchAvailableSpots(String eventId);
}
