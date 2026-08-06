import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/enums/payment_completion.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/complete_payment.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_provider.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockStartPurchase extends Mock implements StartPurchase {}

class _MockCompletePayment extends Mock implements CompletePayment {}

class _MockCancelPendingReservation extends Mock
    implements CancelPendingReservation {}

void main() {
  late _MockStartPurchase startPurchase;
  late _MockCompletePayment completePayment;
  late _MockCancelPendingReservation cancelPending;
  late ProviderContainer container;

  setUp(() {
    startPurchase = _MockStartPurchase();
    completePayment = _MockCompletePayment();
    cancelPending = _MockCancelPendingReservation();
    container = ProviderContainer(
      overrides: <Override>[
        startPurchaseProvider.overrideWithValue(startPurchase),
        completePaymentProvider.overrideWithValue(completePayment),
        cancelPendingReservationProvider.overrideWithValue(cancelPending),
      ],
    );
    container.listen(
      purchaseProvider,
      (PurchaseState? _, PurchaseState _) {},
      fireImmediately: true,
    );
    addTearDown(container.dispose);
  });

  PurchaseNotifier notifier() => container.read(purchaseProvider.notifier);
  PurchaseState state() => container.read(purchaseProvider);

  void mockStart(Result<PurchaseOutcome> result) => when(
    () => startPurchase.call(
      eventId: any(named: 'eventId'),
      unitPrice: any(named: 'unitPrice'),
      quantity: any(named: 'quantity'),
      wantInvoice: any(named: 'wantInvoice'),
    ),
  ).thenAnswer((_) async => result);

  void mockComplete(Result<PaymentCompletion> result) => when(
    () => completePayment.call(sessionId: any(named: 'sessionId')),
  ).thenAnswer((_) async => result);

  void mockCancelOk() =>
      when(() => cancelPending.call(id: any(named: 'id'))).thenAnswer(
        (_) async => const Success<void>(null),
      );

  Future<void> start() => notifier().start(
    eventId: 'evt-1',
    unitPrice: 80000,
    quantity: 2,
    wantInvoice: true,
  );

  /// Deja el flujo esperando el pago, que es la precondición de finishPayment.
  Future<void> reachAwaitingPayment() async {
    mockStart(
      Success<PurchaseOutcome>(
        PurchasePaymentRequired(
          reservation: tReservation(),
          session: tCheckoutSession,
        ),
      ),
    );
    await start();
    expect(state(), isA<PurchaseAwaitingPayment>());
  }

  test('arranca inactivo', () {
    expect(state(), isA<PurchaseIdle>());
  });

  group('start', () {
    test('un evento gratuito queda confirmado sin pasar por el pago', () async {
      mockStart(
        Success<PurchaseOutcome>(
          PurchaseCompleted(
            reservation: tReservation(status: ReservationStatus.confirmed),
          ),
        ),
      );

      await notifier().start(
        eventId: 'evt-1',
        unitPrice: 0,
        quantity: 1,
        wantInvoice: false,
      );

      expect(state(), isA<PurchaseSuccess>());
      expect((state() as PurchaseSuccess).reservation.id, 'res-1');
    });

    test('un evento pago queda esperando el checkout con su sesión', () async {
      await reachAwaitingPayment();

      final PurchaseAwaitingPayment awaiting =
          state() as PurchaseAwaitingPayment;
      expect(awaiting.session.sessionId, 'cs_test_123');
      expect(awaiting.reservation.status, ReservationStatus.pending);
    });

    test('expone el Failure del caso de uso sin traducirlo', () async {
      mockStart(
        const FailureResult<PurchaseOutcome>(
          ValidationFailure('No hay cupos suficientes para este evento'),
        ),
      );

      await start();

      expect(state(), isA<PurchaseFailed>());
      expect(
        (state() as PurchaseFailed).failure.userMessage,
        'No hay cupos suficientes para este evento',
      );
    });

    test('ignora un segundo toque mientras la compra está en curso', () async {
      mockStart(
        Success<PurchaseOutcome>(
          PurchaseCompleted(reservation: tReservation()),
        ),
      );

      // Sin await en el primero: es exactamente el doble toque del usuario.
      final Future<void> first = start();
      await start();
      await first;

      // Cobrar dos veces por un toque doble es el peor error posible aquí.
      verify(
        () => startPurchase.call(
          eventId: any(named: 'eventId'),
          unitPrice: any(named: 'unitPrice'),
          quantity: any(named: 'quantity'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      ).called(1);
    });

    test('ignora un nuevo intento mientras se espera el pago', () async {
      await reachAwaitingPayment();
      clearInteractions(startPurchase);

      await start();

      verifyNever(
        () => startPurchase.call(
          eventId: any(named: 'eventId'),
          unitPrice: any(named: 'unitPrice'),
          quantity: any(named: 'quantity'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      );
    });
  });

  group('finishPayment', () {
    test('no hace nada si no se estaba esperando un pago', () async {
      await notifier().finishPayment(CheckoutResult.success);

      expect(state(), isA<PurchaseIdle>());
      verifyNever(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      );
    });

    test('un pago verificado confirma la reserva pendiente', () async {
      await reachAwaitingPayment();
      mockComplete(
        const Success<PaymentCompletion>(PaymentCompletion.confirmed),
      );

      await notifier().finishPayment(CheckoutResult.success);

      expect(state(), isA<PurchaseSuccess>());
      expect((state() as PurchaseSuccess).reservation.id, 'res-1');
      verify(
        () => completePayment.call(sessionId: 'cs_test_123'),
      ).called(1);
      verifyNever(() => cancelPending.call(id: any(named: 'id')));
    });

    test('cancelar libera el cupo retenido sin verificar nada', () async {
      await reachAwaitingPayment();
      mockCancelOk();

      await notifier().finishPayment(CheckoutResult.cancel);

      expect(state(), isA<PurchaseCancelled>());
      verify(() => cancelPending.call(id: 'res-1')).called(1);
      // Verificar un pago que el usuario abandonó solo gasta una llamada.
      verifyNever(
        () => completePayment.call(sessionId: any(named: 'sessionId')),
      );
    });

    test('si la pasarela no cobró, el cupo se libera', () async {
      await reachAwaitingPayment();
      mockComplete(const Success<PaymentCompletion>(PaymentCompletion.notPaid));
      mockCancelOk();

      await notifier().finishPayment(CheckoutResult.success);

      expect(state(), isA<PurchaseNotPaid>());
      verify(() => cancelPending.call(id: 'res-1')).called(1);
    });

    test('pago cobrado sin reserva confirmada NO libera el cupo', () async {
      await reachAwaitingPayment();
      mockComplete(
        const Success<PaymentCompletion>(
          PaymentCompletion.paidButNotConfirmed,
        ),
      );

      await notifier().finishPayment(CheckoutResult.success);

      expect(state(), isA<PurchaseUnconfirmed>());
      // Hay dinero cobrado: la reserva es el rastro que soporte necesita.
      verifyNever(() => cancelPending.call(id: any(named: 'id')));
    });

    test('si la verificación falla, expone el Failure', () async {
      await reachAwaitingPayment();
      mockComplete(
        const FailureResult<PaymentCompletion>(ConnectionFailure()),
      );

      await notifier().finishPayment(CheckoutResult.success);

      expect(state(), isA<PurchaseFailed>());
      expect((state() as PurchaseFailed).failure, isA<ConnectionFailure>());
      verifyNever(() => cancelPending.call(id: any(named: 'id')));
    });

    test('un fallo al liberar el cupo no tapa el resultado del pago', () async {
      await reachAwaitingPayment();
      mockComplete(const Success<PaymentCompletion>(PaymentCompletion.notPaid));
      when(() => cancelPending.call(id: any(named: 'id'))).thenAnswer(
        (_) async => const FailureResult<void>(ServerFailure()),
      );

      await notifier().finishPayment(CheckoutResult.success);

      // El pending expira solo en 15 min; al usuario se le informa lo del pago.
      expect(state(), isA<PurchaseNotPaid>());
    });
  });
}
