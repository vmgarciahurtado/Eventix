import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:eventix/features/events/infrastructure/repositories/events_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsDatasource extends Mock implements EventsDatasource {}

RemoteEventModel _tEvent() => RemoteEventModel(
  id: 'evt-1',
  title: 'Festival',
  description: 'Una noche increíble',
  categoryId: 1,
  cityId: 2,
  categoryName: 'Reggaetón',
  cityName: 'Bogotá',
  startsAt: DateTime.utc(2026, 7, 4, 20),
  price: 80000,
  capacity: 300,
  imageUrl: 'https://cdn.test/festival.jpg',
);

void main() {
  late _MockEventsDatasource datasource;
  late EventsRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(const EventFilter()));

  setUp(() {
    datasource = _MockEventsDatasource();
    repository = EventsRepositoryImpl(datasource);
  });

  group('getEvents', () {
    test('mapea los modelos remotos a entidades Event', () async {
      when(
        () => datasource.fetchEvents(any()),
      ).thenAnswer((_) async => <RemoteEventModel>[_tEvent()]);

      final Result<List<Event>> result = await repository.getEvents(
        const EventFilter(),
      );

      expect(result, isA<Success<List<Event>>>());
      final List<Event> events = (result as Success<List<Event>>).data;
      expect(events, hasLength(1));
      expect(events.first.title, 'Festival');
      expect(events.first.categoryName, 'Reggaetón');
      expect(events.first.isFree, isFalse);
    });

    test('pasa el filtro tal cual al datasource', () async {
      when(
        () => datasource.fetchEvents(any()),
      ).thenAnswer((_) async => <RemoteEventModel>[]);
      final EventFilter filter = EventFilter(
        categoryId: 3,
        cityId: 2,
        date: DateTime(2026, 7, 4),
      );

      await repository.getEvents(filter);

      // Perder el filtro no rompe nada: la lista ignora lo que se eligió.
      verify(() => datasource.fetchEvents(filter)).called(1);
    });

    test('un catálogo vacío es una lista vacía, no un error', () async {
      when(
        () => datasource.fetchEvents(any()),
      ).thenAnswer((_) async => <RemoteEventModel>[]);

      final Result<List<Event>> result = await repository.getEvents(
        const EventFilter(),
      );

      expect((result as Success<List<Event>>).data, isEmpty);
    });

    test('un error de red llega como Failure', () async {
      when(() => datasource.fetchEvents(any())).thenThrow(
        const ConnectionFailure(),
      );

      final Result<List<Event>> result = await repository.getEvents(
        const EventFilter(),
      );

      expect(
        (result as FailureResult<List<Event>>).failure,
        isA<ConnectionFailure>(),
      );
    });
  });

  group('getEventById', () {
    test('mapea el modelo a entidad conservando el id pedido', () async {
      when(
        () => datasource.fetchEventById(any()),
      ).thenAnswer((_) async => _tEvent());

      final Result<Event> result = await repository.getEventById('evt-1');

      final Event event = (result as Success<Event>).data;
      expect(event.id, 'evt-1');
      expect(event.cityName, 'Bogotá');
      verify(() => datasource.fetchEventById('evt-1')).called(1);
    });

    test('un evento borrado llega como NotFoundFailure', () async {
      when(
        () => datasource.fetchEventById(any()),
      ).thenThrow(const NotFoundFailure());

      final Result<Event> result = await repository.getEventById('evt-404');

      expect(
        (result as FailureResult<Event>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('getCategories', () {
    test('mapea los modelos remotos a entidades Category', () async {
      when(datasource.fetchCategories).thenAnswer(
        (_) async => <RemoteCategoryModel>[
          const RemoteCategoryModel(id: 1, name: 'Música', slug: 'musica'),
        ],
      );

      final Result<List<Category>> result = await repository.getCategories();

      expect(result, isA<Success<List<Category>>>());
      expect((result as Success<List<Category>>).data.first.name, 'Música');
    });

    test('un fallo del catálogo no tumba la pantalla', () async {
      when(datasource.fetchCategories).thenThrow(const ServerFailure());

      final Result<List<Category>> result = await repository.getCategories();

      expect(result, isA<FailureResult<List<Category>>>());
    });
  });

  group('getCities', () {
    test('mapea los modelos remotos a entidades City', () async {
      when(datasource.fetchCities).thenAnswer(
        (_) async => <RemoteCityModel>[
          const RemoteCityModel(id: 2, name: 'Bogotá'),
        ],
      );

      final Result<List<City>> result = await repository.getCities();

      final List<City> cities = (result as Success<List<City>>).data;
      expect(cities.single.id, 2);
      expect(cities.single.name, 'Bogotá');
    });

    test('un fallo llega como Failure', () async {
      when(datasource.fetchCities).thenThrow(const ConnectionFailure());

      expect(await repository.getCities(), isA<FailureResult<List<City>>>());
    });
  });

  group('getAvailableSpots', () {
    test('devuelve el número que calculó la BD sin tocarlo', () async {
      when(
        () => datasource.fetchAvailableSpots(any()),
      ).thenAnswer((_) async => 42);

      final Result<int> result = await repository.getAvailableSpots('evt-1');

      // Este número limita cuántos cupos deja pedir el formulario.
      expect((result as Success<int>).data, 42);
      verify(() => datasource.fetchAvailableSpots('evt-1')).called(1);
    });

    test('un evento agotado es cero, no un error', () async {
      when(
        () => datasource.fetchAvailableSpots(any()),
      ).thenAnswer((_) async => 0);

      expect(
        ((await repository.getAvailableSpots('evt-1')) as Success<int>).data,
        0,
      );
    });

    test('un error inesperado no se filtra crudo al dominio', () async {
      when(
        () => datasource.fetchAvailableSpots(any()),
      ).thenThrow(Exception('boom'));

      final Result<int> result = await repository.getAvailableSpots('evt-1');

      expect((result as FailureResult<int>).failure, isA<UnexpectedFailure>());
    });
  });
}
