import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPaymentsRepository extends Mock implements PaymentsRepository {}

void main() {
  late _MockPaymentsRepository repository;
  late VerifyCheckoutSession usecase;

  setUp(() {
    repository = _MockPaymentsRepository();
    usecase = VerifyCheckoutSession(repository);
  });

  void mockVerify(Result<PaymentVerification> result) => when(
    () => repository.verifyCheckout(sessionId: any(named: 'sessionId')),
  ).thenAnswer((_) async => result);

  test('verifica la sesión que le dieron', () async {
    mockVerify(
      const Success<PaymentVerification>(
        PaymentVerification(paid: true, reservationConfirmed: true),
      ),
    );

    await usecase.call(sessionId: 'cs_test_123');

    verify(() => repository.verifyCheckout(sessionId: 'cs_test_123')).called(1);
  });

  test('no reinterpreta el veredicto del servidor', () async {
    // Pagado sin confirmar es real: el pending expiró y el cupo se revendió.
    mockVerify(
      const Success<PaymentVerification>(
        PaymentVerification(paid: true, reservationConfirmed: false),
      ),
    );

    final Result<PaymentVerification> result = await usecase.call(
      sessionId: 'cs_test_123',
    );

    final PaymentVerification verification =
        (result as Success<PaymentVerification>).data;
    expect(verification.paid, isTrue);
    expect(verification.reservationConfirmed, isFalse);
  });

  test('un fallo no se toma como pago verificado', () async {
    mockVerify(
      const FailureResult<PaymentVerification>(ServerFailure('502')),
    );

    final Result<PaymentVerification> result = await usecase.call(
      sessionId: 'cs_test_123',
    );

    expect(result, isA<FailureResult<PaymentVerification>>());
  });
}
