import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

/// Delegados de una línea, agrupados como en `auth_usecases_test.dart`.
void main() {
  late _MockEventsRepository repository;

  setUpAll(() => registerFallbackValue(const EventFilter()));

  setUp(() => repository = _MockEventsRepository());

  group('GetEvents', () {
    test('entrega el filtro completo al repositorio', () async {
      when(
        () => repository.getEvents(any()),
      ).thenAnswer((_) async => Success<List<Event>>(<Event>[tEvent()]));
      final EventFilter filter = EventFilter(
        categoryId: 3,
        cityId: 2,
        date: DateTime(2026, 7, 4),
      );

      final Result<List<Event>> result = await GetEvents(
        repository,
      ).call(filter);

      expect((result as Success<List<Event>>).data, hasLength(1));
      verify(() => repository.getEvents(filter)).called(1);
    });

    test('un fallo del catálogo no se convierte en lista vacía', () async {
      when(() => repository.getEvents(any())).thenAnswer(
        (_) async => const FailureResult<List<Event>>(ConnectionFailure()),
      );

      // Distinguir "sin eventos" de "no se pudo consultar" decide qué se pinta.
      expect(
        await GetEvents(repository).call(const EventFilter()),
        isA<FailureResult<List<Event>>>(),
      );
    });
  });

  group('GetEventById', () {
    test('consulta el id que le pidieron', () async {
      when(
        () => repository.getEventById(any()),
      ).thenAnswer((_) async => Success<Event>(tEvent(id: 'evt-42')));

      final Result<Event> result = await GetEventById(
        repository,
      ).call('evt-42');

      expect((result as Success<Event>).data.id, 'evt-42');
      verify(() => repository.getEventById('evt-42')).called(1);
    });
  });

  group('GetCategories', () {
    test('devuelve las categorías del repositorio', () async {
      when(repository.getCategories).thenAnswer(
        (_) async => const Success<List<Category>>(tCategories),
      );

      final Result<List<Category>> result = await GetCategories(
        repository,
      ).call();

      expect((result as Success<List<Category>>).data, tCategories);
    });
  });

  group('GetCities', () {
    test('devuelve las ciudades del repositorio', () async {
      when(
        repository.getCities,
      ).thenAnswer((_) async => const Success<List<City>>(tCities));

      final Result<List<City>> result = await GetCities(repository).call();

      expect((result as Success<List<City>>).data, tCities);
    });
  });

  group('GetEventAvailability', () {
    test('consulta los cupos del evento que le pidieron', () async {
      when(
        () => repository.getAvailableSpots(any()),
      ).thenAnswer((_) async => const Success<int>(42));

      final Result<int> result = await GetEventAvailability(
        repository,
      ).call('evt-1');

      // Este número limita cuántos cupos deja pedir el formulario.
      expect((result as Success<int>).data, 42);
      verify(() => repository.getAvailableSpots('evt-1')).called(1);
    });

    test('agotado es cero y sigue siendo un Success', () async {
      when(
        () => repository.getAvailableSpots(any()),
      ).thenAnswer((_) async => const Success<int>(0));

      final Result<int> result = await GetEventAvailability(
        repository,
      ).call('evt-1');

      expect((result as Success<int>).data, 0);
    });
  });
}
