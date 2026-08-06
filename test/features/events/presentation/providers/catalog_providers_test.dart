import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/presentation/providers/categories_provider.dart';
import 'package:eventix/features/events/presentation/providers/cities_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_availability_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_by_id_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:eventix/features/events/presentation/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/test_container.dart';

class _MockGetEvents extends Mock implements GetEvents {}

class _MockGetEventById extends Mock implements GetEventById {}

class _MockGetCategories extends Mock implements GetCategories {}

class _MockGetCities extends Mock implements GetCities {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

void main() {
  late _MockGetEvents getEvents;
  late _MockGetEventById getEventById;
  late _MockGetCategories getCategories;
  late _MockGetCities getCities;
  late _MockGetEventAvailability getAvailability;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(const EventFilter()));

  setUp(() {
    getEvents = _MockGetEvents();
    getEventById = _MockGetEventById();
    getCategories = _MockGetCategories();
    getCities = _MockGetCities();
    getAvailability = _MockGetEventAvailability();
    container = testContainer(
      overrides: <Override>[
        getEventsProvider.overrideWithValue(getEvents),
        getEventByIdProvider.overrideWithValue(getEventById),
        getCategoriesProvider.overrideWithValue(getCategories),
        getCitiesProvider.overrideWithValue(getCities),
        getEventAvailabilityProvider.overrideWithValue(getAvailability),
      ],
    );
    addTearDown(container.dispose);
  });

  group('eventsProvider', () {
    test('expone la lista cuando el caso de uso responde Success', () async {
      when(() => getEvents.call(any())).thenAnswer(
        (_) async => Success<List<Event>>(<Event>[tEvent()]),
      );

      keepAlive(container, eventsProvider);
      final List<Event> events = await container.read(eventsProvider.future);

      expect(events, hasLength(1));
      expect(events.first.title, 'Festival de Reggaetón');
    });

    test('lanza el Failure para que AsyncView muestre su mensaje', () async {
      when(() => getEvents.call(any())).thenAnswer(
        (_) async =>
            const FailureResult<List<Event>>(ConnectionFailure()),
      );

      keepAlive(container, eventsProvider);
      await expectLater(
        container.read(eventsProvider.future),
        throwsA(isA<ConnectionFailure>()),
      );
    });

    test('le pasa al caso de uso el filtro vigente', () async {
      when(() => getEvents.call(any())).thenAnswer(
        (_) async => const Success<List<Event>>(<Event>[]),
      );

      container.read(eventFilterProvider.notifier).setCity(2);
      keepAlive(container, eventsProvider);
      await container.read(eventsProvider.future);

      final EventFilter used =
          verify(() => getEvents.call(captureAny())).captured.last
              as EventFilter;
      expect(used.cityId, 2);
    });

    test('se recalcula cuando cambia el filtro', () async {
      when(() => getEvents.call(any())).thenAnswer(
        (_) async => const Success<List<Event>>(<Event>[]),
      );
      keepAlive(container, eventsProvider);
      await container.read(eventsProvider.future);

      container.read(eventFilterProvider.notifier).setCategory(1);
      await container.read(eventsProvider.future);

      verify(() => getEvents.call(any())).called(2);
    });
  });

  group('eventByIdProvider', () {
    test('consulta el id que recibe como parámetro', () async {
      when(
        () => getEventById.call(any()),
      ).thenAnswer((_) async => Success<Event>(tEvent(id: 'evt-9')));

      keepAlive(container, eventByIdProvider('evt-9'));
      final Event event = await container.read(
        eventByIdProvider('evt-9').future,
      );

      expect(event.id, 'evt-9');
      verify(() => getEventById.call('evt-9')).called(1);
    });

    test('lanza el Failure cuando el evento no existe', () async {
      when(() => getEventById.call(any())).thenAnswer(
        (_) async => const FailureResult<Event>(NotFoundFailure()),
      );

      keepAlive(container, eventByIdProvider('evt-x'));
      await expectLater(
        container.read(eventByIdProvider('evt-x').future),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('eventAvailabilityProvider', () {
    test('expone los cupos libres calculados en BD', () async {
      when(
        () => getAvailability.call(any()),
      ).thenAnswer((_) async => const Success<int>(12));

      keepAlive(container, eventAvailabilityProvider('evt-1'));
      expect(
        await container.read(eventAvailabilityProvider('evt-1').future),
        12,
      );
    });

    test('cachea por evento: cada id se consulta aparte', () async {
      when(
        () => getAvailability.call(any()),
      ).thenAnswer((_) async => const Success<int>(5));

      keepAlive(container, eventAvailabilityProvider('evt-1'));
      keepAlive(container, eventAvailabilityProvider('evt-2'));
      await container.read(eventAvailabilityProvider('evt-1').future);
      await container.read(eventAvailabilityProvider('evt-2').future);

      verify(() => getAvailability.call('evt-1')).called(1);
      verify(() => getAvailability.call('evt-2')).called(1);
    });

    test('lanza el Failure en vez de reportar cero cupos', () async {
      when(() => getAvailability.call(any())).thenAnswer(
        (_) async => const FailureResult<int>(ConnectionFailure()),
      );

      // Devolver 0 diría "agotado" cuando en realidad no se pudo consultar.
      keepAlive(container, eventAvailabilityProvider('evt-1'));
      await expectLater(
        container.read(eventAvailabilityProvider('evt-1').future),
        throwsA(isA<ConnectionFailure>()),
      );
    });
  });

  group('categoriesProvider y citiesProvider', () {
    test('exponen el catálogo para los filtros', () async {
      when(getCategories.call).thenAnswer(
        (_) async => const Success<List<Category>>(tCategories),
      );
      when(getCities.call).thenAnswer(
        (_) async => const Success<List<City>>(tCities),
      );

      keepAlive(container, categoriesProvider);
      keepAlive(container, citiesProvider);
      expect(await container.read(categoriesProvider.future), hasLength(2));
      expect(await container.read(citiesProvider.future), hasLength(2));
    });

    test('propagan el Failure sin dejar la lista a medias', () async {
      when(getCategories.call).thenAnswer(
        (_) async => const FailureResult<List<Category>>(ServerFailure()),
      );

      keepAlive(container, categoriesProvider);
      await expectLater(
        container.read(categoriesProvider.future),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('citiesProvider también propaga su Failure', () async {
      when(getCities.call).thenAnswer(
        (_) async => const FailureResult<List<City>>(ConnectionFailure()),
      );

      // Con la lista vacía el filtro parecería no tener ciudades.
      keepAlive(container, citiesProvider);
      await expectLater(
        container.read(citiesProvider.future),
        throwsA(isA<ConnectionFailure>()),
      );
    });
  });
}
