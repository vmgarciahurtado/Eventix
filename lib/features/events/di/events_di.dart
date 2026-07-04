import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/datasources/supabase_events_datasource.dart';
import 'package:eventix/features/events/infrastructure/repositories/events_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature events: cablea infraestructura y casos de
/// uso exponiendo SOLO interfaces (overridable en tests).
final Provider<EventsDatasource> eventsDatasourceProvider =
    Provider<EventsDatasource>(
      (Ref ref) => SupabaseEventsDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<EventsRepository> eventsRepositoryProvider =
    Provider<EventsRepository>(
      (Ref ref) => EventsRepositoryImpl(ref.watch(eventsDatasourceProvider)),
    );

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

final Provider<GetEventAvailability> getEventAvailabilityProvider =
    Provider<GetEventAvailability>(
      (Ref ref) => GetEventAvailability(ref.watch(eventsRepositoryProvider)),
    );
