import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session.dart';
import 'package:eventix/features/reservations/domain/enums/payment_completion.dart';
import 'package:eventix/features/reservations/domain/usecases/complete_payment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVerifyCheckoutSession extends Mock
    implements VerifyCheckoutSession {}

void main() {
  late _MockVerifyCheckoutSession verifyCheckout;
  late CompletePayment usecase;

  setUp(() {
    verifyCheckout = _MockVerifyCheckoutSession();
    usecase = CompletePayment(verifyCheckout);
  });

  test('maps a paid + confirmed verification to confirmed', () async {
    when(
      () => verifyCheckout.call(sessionId: any(named: 'sessionId')),
    ).thenAnswer(
      (_) async => const Success<PaymentVerification>(
        PaymentVerification(paid: true, reservationConfirmed: true),
      ),
    );

    final Result<PaymentCompletion> result = await usecase.call(
      sessionId: 'cs_test_123',
    );

    expect(
      (result as Success<PaymentCompletion>).data,
      PaymentCompletion.confirmed,
    );
  });

  test('maps an unpaid verification to notPaid', () async {
    when(
      () => verifyCheckout.call(sessionId: any(named: 'sessionId')),
    ).thenAnswer(
      (_) async => const Success<PaymentVerification>(
        PaymentVerification(paid: false, reservationConfirmed: false),
      ),
    );

    final Result<PaymentCompletion> result = await usecase.call(
      sessionId: 'cs_test_123',
    );

    expect(
      (result as Success<PaymentCompletion>).data,
      PaymentCompletion.notPaid,
    );
  });

  test(
    'maps paid-but-unconfirmed (pending expired) to paidButNotConfirmed',
    () async {
      when(
        () => verifyCheckout.call(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => const Success<PaymentVerification>(
          PaymentVerification(paid: true, reservationConfirmed: false),
        ),
      );

      final Result<PaymentCompletion> result = await usecase.call(
        sessionId: 'cs_test_123',
      );

      expect(
        (result as Success<PaymentCompletion>).data,
        PaymentCompletion.paidButNotConfirmed,
      );
    },
  );

  test('propagates a failure from verifyCheckout', () async {
    when(
      () => verifyCheckout.call(sessionId: any(named: 'sessionId')),
    ).thenAnswer(
      (_) async =>
          const FailureResult<PaymentVerification>(ConnectionFailure()),
    );

    final Result<PaymentCompletion> result = await usecase.call(
      sessionId: 'cs_test_123',
    );

    expect(result, isA<FailureResult<PaymentCompletion>>());
  });
}
