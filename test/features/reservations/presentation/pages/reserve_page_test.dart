import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/payments/presentation/pages/checkout_web_view_page.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/enums/payment_completion.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/complete_payment.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_webview.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetEventById extends Mock implements GetEventById {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

class _MockStartPurchase extends Mock implements StartPurchase {}

class _MockCompletePayment extends Mock implements CompletePayment {}

class _MockCancelPendingReservation extends Mock
    implements CancelPendingReservation {}

void main() {
  late _MockGetEventById getEventById;
  late _MockGetEventAvailability getAvailability;
  late _MockStartPurchase startPurchase;
  late _MockCompletePayment completePayment;
  late _MockCancelPendingReservation cancelPending;
  late FakeWebViewPlatform webView;

  setUpAll(initSpanishDates);

  setUp(() {
    getEventById = _MockGetEventById();
    getAvailability = _MockGetEventAvailability();
    startPurchase = _MockStartPurchase();
    completePayment = _MockCompletePayment();
    cancelPending = _MockCancelPendingReservation();
    webView = FakeWebViewPlatform.install();
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => const Success<int>(50));
    when(
      () => cancelPending.call(id: any(named: 'id')),
    ).thenAnswer((_) async => const Success<void>(null));
  });

  Future<void> pumpReserve(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: ReservePage.location('evt-1'),
    overrides: <Override>[
      getEventByIdProvider.overrideWithValue(getEventById),
      getEventAvailabilityProvider.overrideWithValue(getAvailability),
      startPurchaseProvider.overrideWithValue(startPurchase),
      completePaymentProvider.overrideWithValue(completePayment),
      cancelPendingReservationProvider.overrideWithValue(cancelPending),
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

  /// Avanza el reloj a mano: el `UiLoader` es un Lottie en bucle y
  /// `pumpAndSettle` nunca vuelve.
  Future<void> advance(WidgetTester tester) async {
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  /// Deja la compra en el punto donde el WebView de pago ya está abierto.
  Future<void> openCheckout(WidgetTester tester) async {
    mockEvent(Success<Event>(tEvent()));
    mockPurchase(
      Success<PurchaseOutcome>(
        PurchasePaymentRequired(
          reservation: tReservation(),
          session: tCheckoutSession,
        ),
      ),
    );

    await pumpReserve(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Pagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await advance(tester);
  }

  /// Simula que la pasarela devolvió al usuario con [status].
  Future<void> returnFromGateway(WidgetTester tester, String? status) async {
    final String query = status == null ? '' : '?status=$status';
    await webView.controller!.navigateTo(
      'https://proyecto.supabase.test/functions/v1'
      '${tCheckoutSession.returnUrlMarker}$query',
    );
    await advance(tester);
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

  testWidgets('reintentar vuelve a consultar el evento', (
    WidgetTester tester,
  ) async {
    mockEvent(const FailureResult<Event>(ConnectionFailure()));

    await pumpReserve(tester);
    await tester.pumpAndSettle();

    mockEvent(Success<Event>(tEvent()));
    await tester.tap(find.widgetWithText(UiButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(ReserveForm), findsOneWidget);
    expect(find.byType(AsyncErrorView), findsNothing);
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

  group('evento pago', () {
    testWidgets('una reserva pendiente abre el checkout de la pasarela', (
      WidgetTester tester,
    ) async {
      await openCheckout(tester);

      expect(find.byType(CheckoutWebViewPage), findsOneWidget);
      expect(webView.controller!.loadedUrl.toString(), tCheckoutSession.url);
    });

    testWidgets('con la compra en curso la factura queda congelada', (
      WidgetTester tester,
    ) async {
      mockEvent(Success<Event>(tEvent()));
      final Completer<Result<PurchaseOutcome>> pending =
          Completer<Result<PurchaseOutcome>>();
      when(
        () => startPurchase.call(
          eventId: any(named: 'eventId'),
          unitPrice: any(named: 'unitPrice'),
          quantity: any(named: 'quantity'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      ).thenAnswer((_) => pending.future);

      await pumpReserve(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Pagar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pump();

      final UiCheckOption invoice = tester.widget<UiCheckOption>(
        find.byType(UiCheckOption),
      );
      final bool before = invoice.value;
      invoice.onChanged(!before);
      await tester.pump();

      expect(
        tester.widget<UiCheckOption>(find.byType(UiCheckOption)).value,
        before,
      );

      pending.complete(
        Success<PurchaseOutcome>(
          PurchasePaymentRequired(
            reservation: tReservation(),
            session: tCheckoutSession,
          ),
        ),
      );
      await advance(tester);
    });

    testWidgets('un pago verificado navega a la confirmación', (
      WidgetTester tester,
    ) async {
      when(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => const Success<PaymentCompletion>(
          PaymentCompletion.confirmed,
        ),
      );

      await openCheckout(tester);
      await returnFromGateway(tester, 'success');
      await tester.pumpAndSettle();

      expect(find.text('CONFIRMADA'), findsOneWidget);
      verify(
        () => completePayment.call(sessionId: tCheckoutSession.sessionId),
      ).called(1);
    });

    testWidgets('cancelar libera el cupo retenido y avisa', (
      WidgetTester tester,
    ) async {
      await openCheckout(tester);
      await returnFromGateway(tester, 'cancel');

      expect(
        find.widgetWithText(
          SnackBar,
          'Pago cancelado. No se realizó la reserva.',
        ),
        findsOneWidget,
      );
      // Sin esto el cupo queda retenido hasta que expire el pending.
      verify(() => cancelPending.call(id: 'res-1')).called(1);
      // Cancelar no se verifica contra la pasarela: no hay nada que verificar.
      verifyNever(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      );
      expect(find.text('CONFIRMADA'), findsNothing);
    });

    testWidgets('cerrar el checkout con la X cuenta como cancelar', (
      WidgetTester tester,
    ) async {
      await openCheckout(tester);

      await tester.tap(find.byIcon(Icons.close));
      await advance(tester);

      expect(
        find.widgetWithText(
          SnackBar,
          'Pago cancelado. No se realizó la reserva.',
        ),
        findsOneWidget,
      );
      verify(() => cancelPending.call(id: 'res-1')).called(1);
    });

    testWidgets('volver sin cobro avisa y libera el cupo', (
      WidgetTester tester,
    ) async {
      when(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async =>
            const Success<PaymentCompletion>(PaymentCompletion.notPaid),
      );

      await openCheckout(tester);
      await returnFromGateway(tester, 'success');

      // La pasarela dijo éxito pero el servidor no vio el cobro.
      expect(
        find.widgetWithText(
          SnackBar,
          'El pago no se completó. No se realizó la reserva.',
        ),
        findsOneWidget,
      );
      verify(() => cancelPending.call(id: 'res-1')).called(1);
      expect(find.text('CONFIRMADA'), findsNothing);
    });

    testWidgets('un pago cobrado sin reserva no borra nada y pide soporte', (
      WidgetTester tester,
    ) async {
      when(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => const Success<PaymentCompletion>(
          PaymentCompletion.paidButNotConfirmed,
        ),
      );

      await openCheckout(tester);
      await returnFromGateway(tester, 'success');

      expect(
        find.widgetWithText(
          SnackBar,
          'Recibimos tu pago pero la reserva no pudo confirmarse. '
          'Escríbenos para resolverlo.',
        ),
        findsOneWidget,
      );
      // El usuario pagó: la reserva es el rastro que necesita soporte.
      verifyNever(() => cancelPending.call(id: any(named: 'id')));
      expect(find.text('CONFIRMADA'), findsNothing);
    });

    testWidgets('si la verificación falla se avisa sin dar el pago por bueno', (
      WidgetTester tester,
    ) async {
      when(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => const FailureResult<PaymentCompletion>(
          ConnectionFailure(),
        ),
      );

      await openCheckout(tester);
      await returnFromGateway(tester, 'success');

      expect(
        find.widgetWithText(SnackBar, 'Sin conexión a internet'),
        findsOneWidget,
      );
      expect(find.text('CONFIRMADA'), findsNothing);
    });
  });
}
