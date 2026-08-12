import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session_use_case.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation_use_case.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreateReservation extends Mock implements CreateReservationUseCase {}

class _MockCancelPendingReservation extends Mock
    implements CancelPendingReservationUseCase {}

class _MockCreateCheckoutSession extends Mock
    implements CreateCheckoutSessionUseCase {}

Reservation _tReservation({
  ReservationStatus status = ReservationStatus.pending,
}) {
  return Reservation(
    id: 'res-1',
    eventTitle: 'Festival',
    quantity: 2,
    status: status,
    createdAt: DateTime.utc(2026, 6, 29),
    eventStartsAt: DateTime.utc(2026, 7, 4, 20),
  );
}

const CheckoutSession _tSession = CheckoutSession(
  url: 'https://checkout.stripe.test/abc',
  sessionId: 'cs_test_123',
  returnUrlMarker: '/stripe-return',
);

void main() {
  late _MockCreateReservation createReservation;
  late _MockCancelPendingReservation cancelPendingReservation;
  late _MockCreateCheckoutSession createCheckout;
  late StartPurchaseUseCase usecase;

  setUpAll(() {
    registerFallbackValue(ReservationStatus.pending);
  });

  setUp(() {
    createReservation = _MockCreateReservation();
    cancelPendingReservation = _MockCancelPendingReservation();
    createCheckout = _MockCreateCheckoutSession();
    usecase = StartPurchaseUseCase(
      createReservation: createReservation,
      cancelPendingReservation: cancelPendingReservation,
      createCheckout: createCheckout,
    );
  });

  group('free event', () {
    test(
      'creates a confirmed reservation and completes without checkout',
      () async {
        when(
          () => createReservation.call(
            eventId: any(named: 'eventId'),
            quantity: any(named: 'quantity'),
            initialStatus: any(named: 'initialStatus'),
          ),
        ).thenAnswer(
          (_) async => Success<Reservation>(
            _tReservation(status: ReservationStatus.confirmed),
          ),
        );

        final Result<PurchaseOutcome> result = await usecase.call(
          eventId: 'evt-1',
          unitPrice: 0,
          quantity: 2,
          wantInvoice: false,
        );

        expect(result, isA<Success<PurchaseOutcome>>());
        expect(
          (result as Success<PurchaseOutcome>).data,
          isA<PurchaseCompleted>(),
        );
        // Un evento gratuito nace confirmado y NO toca el checkout.
        verify(
          () => createReservation.call(
            eventId: 'evt-1',
            quantity: 2,
            initialStatus: ReservationStatus.confirmed,
          ),
        ).called(1);
        verifyNever(
          () => createCheckout.call(
            reservationId: any(named: 'reservationId'),
            wantInvoice: any(named: 'wantInvoice'),
          ),
        );
      },
    );
  });

  group('paid event', () {
    test('creates a pending reservation then a checkout session', () async {
      when(
        () => createReservation.call(
          eventId: any(named: 'eventId'),
          quantity: any(named: 'quantity'),
          initialStatus: any(named: 'initialStatus'),
        ),
      ).thenAnswer((_) async => Success<Reservation>(_tReservation()));
      when(
        () => createCheckout.call(
          reservationId: any(named: 'reservationId'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      ).thenAnswer((_) async => const Success<CheckoutSession>(_tSession));

      final Result<PurchaseOutcome> result = await usecase.call(
        eventId: 'evt-1',
        unitPrice: 80000,
        quantity: 2,
        wantInvoice: true,
      );

      expect(result, isA<Success<PurchaseOutcome>>());
      final PurchaseOutcome outcome = (result as Success<PurchaseOutcome>).data;
      expect(outcome, isA<PurchasePaymentRequired>());
      expect((outcome as PurchasePaymentRequired).session, _tSession);
      verify(
        () => createReservation.call(
          eventId: 'evt-1',
          quantity: 2,
          initialStatus: ReservationStatus.pending,
        ),
      ).called(1);
      verify(
        () => createCheckout.call(reservationId: 'res-1', wantInvoice: true),
      ).called(1);
    });

    test(
      'cancels the pending reservation when the checkout cannot be created',
      () async {
        when(
          () => createReservation.call(
            eventId: any(named: 'eventId'),
            quantity: any(named: 'quantity'),
            initialStatus: any(named: 'initialStatus'),
          ),
        ).thenAnswer((_) async => Success<Reservation>(_tReservation()));
        when(
          () => createCheckout.call(
            reservationId: any(named: 'reservationId'),
            wantInvoice: any(named: 'wantInvoice'),
          ),
        ).thenAnswer(
          (_) async => const FailureResult<CheckoutSession>(ServerFailure()),
        );
        when(
          () => cancelPendingReservation.call(id: any(named: 'id')),
        ).thenAnswer((_) async => const Success<void>(null));

        final Result<PurchaseOutcome> result = await usecase.call(
          eventId: 'evt-1',
          unitPrice: 80000,
          quantity: 2,
          wantInvoice: false,
        );

        expect(result, isA<FailureResult<PurchaseOutcome>>());
        // No debe quedar cupo retenido si el pago no pudo iniciarse.
        verify(
          () => cancelPendingReservation.call(id: 'res-1'),
        ).called(1);
      },
    );

    test(
      'propagates the failure when the reservation cannot be created',
      () async {
        when(
          () => createReservation.call(
            eventId: any(named: 'eventId'),
            quantity: any(named: 'quantity'),
            initialStatus: any(named: 'initialStatus'),
          ),
        ).thenAnswer(
          (_) async => const FailureResult<Reservation>(
            ValidationFailure('No hay cupos suficientes para este evento'),
          ),
        );

        final Result<PurchaseOutcome> result = await usecase.call(
          eventId: 'evt-1',
          unitPrice: 80000,
          quantity: 2,
          wantInvoice: false,
        );

        expect(result, isA<FailureResult<PurchaseOutcome>>());
        expect(
          (result as FailureResult<PurchaseOutcome>).failure,
          isA<ValidationFailure>(),
        );
        verifyNever(
          () => createCheckout.call(
            reservationId: any(named: 'reservationId'),
            wantInvoice: any(named: 'wantInvoice'),
          ),
        );
      },
    );
  });
}
