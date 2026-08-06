import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/datasources/supabase_events_datasource.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_supabase.dart';

Map<String, dynamic> _eventRow({String id = 'evt-1'}) => <String, dynamic>{
  'id': id,
  'title': 'Festival de Reggaetón',
  'description': 'Una noche increíble',
  'category_id': 1,
  'city_id': 2,
  'starts_at': '2026-07-04T20:00:00Z',
  'price': 80000,
  'capacity': 300,
  'image_url': 'https://cdn.test/festival.jpg',
  'categories': <String, dynamic>{'name': 'Reggaetón'},
  'cities': <String, dynamic>{'name': 'Bogotá'},
};

void main() {
  late FakeSupabase supabase;

  void useResponse(Object? body) {
    supabase = FakeSupabase.replying(body);
    addTearDown(supabase.dispose);
  }

  void useFailure({int status = 500}) {
    supabase = FakeSupabase.failing(status: status);
    addTearDown(supabase.dispose);
  }

  SupabaseEventsDatasource datasource() =>
      SupabaseEventsDatasource(supabase.client);

  group('fetchEvents', () {
    test('consulta events con los joins de categoría y ciudad', () async {
      useResponse(<Map<String, dynamic>>[_eventRow()]);

      final List<RemoteEventModel> events = await datasource().fetchEvents(
        const EventFilter(),
      );

      expect(supabase.lastUri.path, endsWith('/rest/v1/events'));
      expect(
        supabase.lastQuery['select'],
        '*,categories(name),cities(name)',
        reason: 'sin los joins la tarjeta no tendría nombre de ciudad',
      );
      expect(events.single.categoryName, 'Reggaetón');
      expect(events.single.cityName, 'Bogotá');
    });

    test('ordena por fecha de inicio', () async {
      useResponse(<Map<String, dynamic>>[]);

      await datasource().fetchEvents(const EventFilter());

      expect(supabase.lastQuery['order'], contains('starts_at'));
    });

    test('sin filtros no manda ninguna condición', () async {
      useResponse(<Map<String, dynamic>>[]);

      await datasource().fetchEvents(const EventFilter());

      expect(supabase.lastQuery.containsKey('category_id'), isFalse);
      expect(supabase.lastQuery.containsKey('city_id'), isFalse);
      expect(supabase.lastQuery.containsKey('starts_at'), isFalse);
    });

    test('filtra por categoría y ciudad cuando vienen en el filtro', () async {
      useResponse(<Map<String, dynamic>>[]);

      await datasource().fetchEvents(
        const EventFilter(categoryId: 3, cityId: 7),
      );

      expect(supabase.lastQuery['category_id'], 'eq.3');
      expect(supabase.lastQuery['city_id'], 'eq.7');
    });

    test('la fecha se convierte en la ventana del día, serializada en UTC',
        () async {
      useResponse(<Map<String, dynamic>>[]);

      // `starts_at` es timestamptz: sin convertir, Postgres lo corre de zona.
      final DateTime day = DateTime(2026, 7, 4, 15, 30);
      await datasource().fetchEvents(EventFilter(date: day));

      final String? from = supabase.lastQuery['starts_at'];
      expect(from, isNotNull);
      expect(
        supabase.lastUri.query,
        contains(
          Uri.encodeQueryComponent(
            'gte.${DateTime(2026, 7, 4).toUtc().toIso8601String()}',
          ),
        ),
      );
      expect(
        supabase.lastUri.query,
        contains(
          Uri.encodeQueryComponent(
            'lt.${DateTime(2026, 7, 5).toUtc().toIso8601String()}',
          ),
        ),
      );
    });

    test('un error del servidor se traduce a Failure', () async {
      useFailure();

      expect(
        () => datasource().fetchEvents(const EventFilter()),
        throwsA(isA<Failure>()),
      );
    });
  });

  group('fetchEventById', () {
    test('filtra por id y pide una sola fila', () async {
      useResponse(_eventRow(id: 'evt-9'));

      final RemoteEventModel event = await datasource().fetchEventById(
        'evt-9',
      );

      expect(supabase.lastQuery['id'], 'eq.evt-9');
      expect(event.id, 'evt-9');
    });

    test('si el evento no existe lanza NotFoundFailure', () async {
      // PostgREST responde `null` con maybeSingle cuando no hay fila.
      useResponse(null);

      expect(
        () => datasource().fetchEventById('evt-x'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('fetchAvailableSpots', () {
    test('lee la vista de disponibilidad para ese evento', () async {
      useResponse(<String, dynamic>{'available': 12});

      final int available = await datasource().fetchAvailableSpots('evt-1');

      expect(supabase.lastUri.path, endsWith('/rest/v1/event_availability'));
      expect(supabase.lastQuery['event_id'], 'eq.evt-1');
      expect(supabase.lastQuery['select'], 'available');
      expect(available, 12);
    });

    test('acepta el conteo como double', () async {
      useResponse(<String, dynamic>{'available': 12.0});

      expect(await datasource().fetchAvailableSpots('evt-1'), 12);
    });
  });

  group('catálogo', () {
    test('categorías salen ordenadas por nombre', () async {
      useResponse(<Map<String, dynamic>>[
        <String, dynamic>{'id': 1, 'name': 'Reggaetón', 'slug': 'reggaeton'},
      ]);

      final List<RemoteCategoryModel> categories = await datasource()
          .fetchCategories();

      expect(supabase.lastUri.path, endsWith('/rest/v1/categories'));
      expect(supabase.lastQuery['order'], contains('name'));
      expect(categories.single.name, 'Reggaetón');
    });

    test('ciudades salen ordenadas por nombre', () async {
      useResponse(<Map<String, dynamic>>[
        <String, dynamic>{'id': 2, 'name': 'Medellín'},
      ]);

      final List<RemoteCityModel> cities = await datasource().fetchCities();

      expect(supabase.lastUri.path, endsWith('/rest/v1/cities'));
      expect(supabase.lastQuery['order'], contains('name'));
      expect(cities.single.name, 'Medellín');
    });
  });
}
