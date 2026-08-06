import 'dart:async';

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
import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/events/routes/events_routes.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

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

  setUpAll(() {
    unawaited(initSpanishDates());
    registerFallbackValue(const EventFilter());
  });

  setUp(() {
    getEvents = _MockGetEvents();
    getEventById = _MockGetEventById();
    getCategories = _MockGetCategories();
    getCities = _MockGetCities();
    getAvailability = _MockGetEventAvailability();
    when(
      () => getEvents.call(any()),
    ).thenAnswer((_) async => Success<List<Event>>(<Event>[tEvent()]));
    when(
      () => getEventById.call(any()),
    ).thenAnswer((_) async => Success<Event>(tEvent(id: 'evt-42')));
    when(
      getCategories.call,
    ).thenAnswer((_) async => const Success<List<Category>>(tCategories));
    when(
      getCities.call,
    ).thenAnswer((_) async => const Success<List<City>>(tCities));
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => const Success<int>(50));
  });

  Future<void> pumpAt(WidgetTester tester, String location) => pumpRoutes(
    tester,
    initialLocation: location,
    overrides: <Override>[
      getEventsProvider.overrideWithValue(getEvents),
      getEventByIdProvider.overrideWithValue(getEventById),
      getCategoriesProvider.overrideWithValue(getCategories),
      getCitiesProvider.overrideWithValue(getCities),
      getEventAvailabilityProvider.overrideWithValue(getAvailability),
    ],
    routes: eventsRoutes,
  );

  testWidgets('/events abre el catálogo', (WidgetTester tester) async {
    await pumpAt(tester, EventsPage.routePath);
    await tester.pumpAndSettle();

    expect(find.byType(EventsPage), findsOneWidget);
  });

  testWidgets('la URL que arma EventDetailPage.location casa con su ruta', (
    WidgetTester tester,
  ) async {
    // `location()` y `routePath` son dos strings aparte: si uno cambia, 404.
    await pumpAt(tester, EventDetailPage.location('evt-42'));
    await tester.pumpAndSettle();

    expect(find.byType(EventDetailPage), findsOneWidget);
  });

  testWidgets('el id del path llega al evento que se consulta', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, EventDetailPage.location('evt-42'));
    await tester.pumpAndSettle();

    // Leer mal el parámetro no falla: abre el detalle de otro evento.
    verify(() => getEventById.call('evt-42')).called(1);
  });
}
