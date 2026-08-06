import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockPaymentsRepository extends Mock implements PaymentsRepository {}

/// Delegado de una línea: no debe alterar lo que le pasan ni lo que devuelve.
void main() {
  late _MockPaymentsRepository repository;
  late CreateCheckoutSession usecase;

  setUp(() {
    repository = _MockPaymentsRepository();
    usecase = CreateCheckoutSession(repository);
  });

  void mockCreate(Result<CheckoutSession> result) => when(
    () => repository.createCheckout(
      reservationId: any(named: 'reservationId'),
      wantInvoice: any(named: 'wantInvoice'),
    ),
  ).thenAnswer((_) async => result);

  test('cobra la reserva que le dieron y respeta la factura', () async {
    mockCreate(const Success<CheckoutSession>(tCheckoutSession));

    await usecase.call(reservationId: 'res-1', wantInvoice: true);

    // Un id equivocado cobraría otra reserva; un wantInvoice fijo, mal.
    verify(
      () =>
          repository.createCheckout(reservationId: 'res-1', wantInvoice: true),
    ).called(1);
  });

  test('pedir sin factura llega sin factura', () async {
    mockCreate(const Success<CheckoutSession>(tCheckoutSession));

    await usecase.call(reservationId: 'res-1', wantInvoice: false);

    verify(
      () =>
          repository.createCheckout(reservationId: 'res-1', wantInvoice: false),
    ).called(1);
  });

  test('devuelve la sesión tal como vino del repositorio', () async {
    mockCreate(const Success<CheckoutSession>(tCheckoutSession));

    final Result<CheckoutSession> result = await usecase.call(
      reservationId: 'res-1',
      wantInvoice: false,
    );

    expect((result as Success<CheckoutSession>).data, same(tCheckoutSession));
  });

  test('un fallo del repositorio no se convierte en sesión', () async {
    mockCreate(const FailureResult<CheckoutSession>(ConnectionFailure()));

    final Result<CheckoutSession> result = await usecase.call(
      reservationId: 'res-1',
      wantInvoice: false,
    );

    expect(result, isA<FailureResult<CheckoutSession>>());
    expect(
      (result as FailureResult<CheckoutSession>).failure,
      isA<ConnectionFailure>(),
    );
  });
}
