import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:eventix/features/reservations/routes/reservations_routes.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';

class _MockGetMyReservations extends Mock implements GetMyReservations {}

class _MockGetEventById extends Mock implements GetEventById {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

void main() {
  late _MockGetMyReservations getMyReservations;
  late _MockGetEventById getEventById;
  late _MockGetEventAvailability getAvailability;

  setUpAll(initSpanishDates);

  setUp(() {
    getMyReservations = _MockGetMyReservations();
    getEventById = _MockGetEventById();
    getAvailability = _MockGetEventAvailability();
    when(
      getMyReservations.call,
    ).thenAnswer(
      (_) async => const Success<List<Reservation>>(<Reservation>[]),
    );
    when(
      () => getEventById.call(any()),
    ).thenAnswer((_) async => Success<Event>(tEvent()));
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => const Success<int>(50));
  });

  Future<void> pumpAt(WidgetTester tester, String location) => pumpRoutes(
    tester,
    initialLocation: location,
    overrides: <Override>[
      getMyReservationsProvider.overrideWithValue(getMyReservations),
      getEventByIdProvider.overrideWithValue(getEventById),
      getEventAvailabilityProvider.overrideWithValue(getAvailability),
    ],
    routes: <RouteBase>[
      ...reservationsRoutes,
      stubRoute(EventsPage.routePath, 'CATALOGO'),
    ],
  );

  testWidgets('/reservations abre la lista de reservas', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, MyReservationsPage.routePath);
    await tester.pumpAndSettle();

    expect(find.byType(MyReservationsPage), findsOneWidget);
  });

  testWidgets('/reservation-confirmed abre la confirmación', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, ReservationConfirmedPage.routePath);
    await tester.pumpAndSettle();

    expect(find.byType(ReservationConfirmedPage), findsOneWidget);
  });

  testWidgets('la URL que arma ReservePage.location casa con su ruta', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, ReservePage.location('evt-42'));
    await tester.pumpAndSettle();

    expect(find.byType(ReservePage), findsOneWidget);
  });

  testWidgets('el id del path llega al evento que se consulta', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, ReservePage.location('evt-42'));
    await tester.pumpAndSettle();

    verify(() => getEventById.call('evt-42')).called(1);
  });
}
