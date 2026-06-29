import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/datasources/supabase_events_datasource.dart';
import 'package:eventix/features/events/infrastructure/repositories/events_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

// --- Infraestructura ---
final Provider<EventsDatasource> eventsDatasourceProvider =
    Provider<EventsDatasource>(
      (Ref ref) => SupabaseEventsDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<EventsRepository> eventsRepositoryProvider =
    Provider<EventsRepository>(
      (Ref ref) => EventsRepositoryImpl(ref.watch(eventsDatasourceProvider)),
    );

// --- Casos de uso ---
final Provider<GetEvents> getEventsProvider = Provider<GetEvents>(
  (Ref ref) => GetEvents(ref.watch(eventsRepositoryProvider)),
);

final Provider<GetEventById> getEventByIdProvider = Provider<GetEventById>(
  (Ref ref) => GetEventById(ref.watch(eventsRepositoryProvider)),
);

final Provider<GetCategories> getCategoriesProvider = Provider<GetCategories>(
  (Ref ref) => GetCategories(ref.watch(eventsRepositoryProvider)),
);

final Provider<GetCities> getCitiesProvider = Provider<GetCities>(
  (Ref ref) => GetCities(ref.watch(eventsRepositoryProvider)),
);

// --- Estado de filtros ---
class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => const EventFilter();

  void setCategory(int? id) =>
      state = state.copyWith(categoryId: id, clearCategory: id == null);

  void setCity(int? id) =>
      state = state.copyWith(cityId: id, clearCity: id == null);

  void setDate(DateTime? date) =>
      state = state.copyWith(date: date, clearDate: date == null);

  void clear() => state = const EventFilter();
}

final NotifierProvider<EventFilterNotifier, EventFilter> eventFilterProvider =
    NotifierProvider<EventFilterNotifier, EventFilter>(
      EventFilterNotifier.new,
    );

// --- Catálogos ---
final FutureProvider<List<Category>> categoriesProvider =
    FutureProvider<List<Category>>((Ref ref) async {
      final Result<List<Category>> result = await ref
          .watch(getCategoriesProvider)
          .call();
      return result.getOrThrow();
    });

final FutureProvider<List<City>> citiesProvider = FutureProvider<List<City>>((
  Ref ref,
) async {
  final Result<List<City>> result = await ref.watch(getCitiesProvider).call();
  return result.getOrThrow();
});

// --- Listado de eventos (reacciona al filtro) ---
final FutureProvider<List<Event>> eventsProvider = FutureProvider<List<Event>>((
  Ref ref,
) async {
  final EventFilter filter = ref.watch(eventFilterProvider);
  final Result<List<Event>> result = await ref
      .watch(getEventsProvider)
      .call(filter);
  return result.getOrThrow();
});

// --- Detalle de evento ---
final FutureProviderFamily<Event, String> eventByIdProvider =
    FutureProvider.family<Event, String>((Ref ref, String id) async {
      final Result<Event> result = await ref
          .watch(getEventByIdProvider)
          .call(id);
      return result.getOrThrow();
    });
