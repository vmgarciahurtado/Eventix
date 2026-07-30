import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetEventById extends Mock implements GetEventById {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

class _MockStartPurchase extends Mock implements StartPurchase {}

void main() {
  late _MockGetEventById getEventById;
  late _MockGetEventAvailability getAvailability;
  late _MockStartPurchase startPurchase;

  setUpAll(initSpanishDates);

  setUp(() {
    getEventById = _MockGetEventById();
    getAvailability = _MockGetEventAvailability();
    startPurchase = _MockStartPurchase();
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => const Success<int>(50));
  });

  Future<void> pumpReserve(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: ReservePage.location('evt-1'),
    overrides: <Override>[
      getEventByIdProvider.overrideWithValue(getEventById),
      getEventAvailabilityProvider.overrideWithValue(getAvailability),
      startPurchaseProvider.overrideWithValue(startPurchase),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: ReservePage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            ReservePage(eventId: state.pathParameters['id']!),
      ),
      stubRoute(ReservationConfirmedPage.routePath, 'CONFIRMADA'),
    ],
  );

  void mockEvent(Result<Event> result) =>
      when(() => getEventById.call(any())).thenAnswer((_) async => result);

  void mockPurchase(Result<PurchaseOutcome> result) => when(
    () => startPurchase.call(
      eventId: any(named: 'eventId'),
      unitPrice: any(named: 'unitPrice'),
      quantity: any(named: 'quantity'),
      wantInvoice: any(named: 'wantInvoice'),
    ),
  ).thenAnswer((_) async => result);

  Future<void> confirmFreePurchase(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(UiButton, 'Reservar gratis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
  }

  testWidgets('mientras carga el evento muestra el loader', (
    WidgetTester tester,
  ) async {
    mockEvent(Success<Event>(tEvent()));

    await pumpReserve(tester);

    expect(find.byType(AppLoadingView), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('carga el evento del id de la ruta', (
    WidgetTester tester,
  ) async {
    mockEvent(Success<Event>(tEvent()));

    await pumpReserve(tester);
    await tester.pumpAndSettle();

    verify(() => getEventById.call('evt-1')).called(1);
    expect(find.byType(ReserveForm), findsOneWidget);
  });

  testWidgets('un evento inexistente muestra el error con reintento', (
    WidgetTester tester,
  ) async {
    mockEvent(const FailureResult<Event>(NotFoundFailure()));

    await pumpReserve(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AsyncErrorView), findsOneWidget);
    expect(find.text('Recurso no encontrado'), findsOneWidget);
    expect(find.widgetWithText(UiButton, 'Reintentar'), findsOneWidget);
  });

  testWidgets('una reserva gratuita confirmada navega a la confirmación', (
    WidgetTester tester,
  ) async {
    mockEvent(Success<Event>(tEvent(price: 0)));
    mockPurchase(
      Success<PurchaseOutcome>(
        PurchaseCompleted(
          reservation: tReservation(status: ReservationStatus.confirmed),
        ),
      ),
    );

    await pumpReserve(tester);
    await tester.pumpAndSettle();
    await confirmFreePurchase(tester);

    expect(find.text('CONFIRMADA'), findsOneWidget);
  });

  testWidgets('un fallo de la compra avisa y deja al usuario en la pantalla', (
    WidgetTester tester,
  ) async {
    mockEvent(Success<Event>(tEvent(price: 0)));
    mockPurchase(
      const FailureResult<PurchaseOutcome>(
        ValidationFailure('No hay cupos suficientes para este evento'),
      ),
    );

    await pumpReserve(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(UiButton, 'Reservar gratis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(
      find.widgetWithText(
        SnackBar,
        'No hay cupos suficientes para este evento',
      ),
      findsOneWidget,
    );
    expect(find.text('CONFIRMADA'), findsNothing);
  });

  testWidgets('tras un fallo se vuelve a consultar la disponibilidad', (
    WidgetTester tester,
  ) async {
    mockEvent(Success<Event>(tEvent(price: 0)));
    mockPurchase(
      const FailureResult<PurchaseOutcome>(ValidationFailure('Sin cupos')),
    );

    await pumpReserve(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(UiButton, 'Reservar gratis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // El cupo pudo haberlo tomado otro: refrescar evita reintentar a ciegas.
    verify(() => getAvailability.call('evt-1')).called(greaterThan(1));
  });
}
