import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

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

// --- Cupos disponibles (capacidad − reservas activas, calculado en BD) ---
final FutureProviderFamily<int, String> eventAvailabilityProvider =
    FutureProvider.family<int, String>((Ref ref, String id) async {
      final Result<int> result = await ref
          .watch(getEventAvailabilityProvider)
          .call(id);
      return result.getOrThrow();
    });
