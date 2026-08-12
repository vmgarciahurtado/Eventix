import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/domain/usecases/get_categories_use_case.dart';
import 'package:eventix/features/events/domain/usecases/get_cities_use_case.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability_use_case.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id_use_case.dart';
import 'package:eventix/features/events/domain/usecases/get_events_use_case.dart';
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

final Provider<GetEventsUseCase> getEventsProvider = Provider<GetEventsUseCase>(
  (Ref ref) => GetEventsUseCase(ref.watch(eventsRepositoryProvider)),
);

final Provider<GetEventByIdUseCase> getEventByIdProvider =
    Provider<GetEventByIdUseCase>(
      (Ref ref) => GetEventByIdUseCase(ref.watch(eventsRepositoryProvider)),
    );

final Provider<GetCategoriesUseCase> getCategoriesProvider =
    Provider<GetCategoriesUseCase>(
      (Ref ref) => GetCategoriesUseCase(ref.watch(eventsRepositoryProvider)),
    );

final Provider<GetCitiesUseCase> getCitiesProvider = Provider<GetCitiesUseCase>(
  (Ref ref) => GetCitiesUseCase(ref.watch(eventsRepositoryProvider)),
);

final Provider<GetEventAvailabilityUseCase> getEventAvailabilityProvider =
    Provider<GetEventAvailabilityUseCase>(
      (Ref ref) =>
          GetEventAvailabilityUseCase(ref.watch(eventsRepositoryProvider)),
    );
