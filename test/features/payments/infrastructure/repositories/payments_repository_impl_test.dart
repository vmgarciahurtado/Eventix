import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/entities/payment_verification.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:eventix/features/payments/infrastructure/mappers/checkout_session_mapper.dart';
import 'package:eventix/features/payments/infrastructure/mappers/payment_verification_mapper.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_checkout_session_model.dart';
import 'package:eventix/features/payments/infrastructure/models/remote_payment_verification_model.dart';
import 'package:eventix/features/payments/infrastructure/repositories/payments_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPaymentsDatasource extends Mock implements PaymentsDatasource {}

/// El datasource de payments ya devuelve entidades: mapea allí, no acá.
const RemoteCheckoutSessionModel _tModel = RemoteCheckoutSessionModel(
  url: 'https://checkout.stripe.test/cs_test_123',
  sessionId: 'cs_test_123',
  returnUrlMarker: '/stripe-return',
);

const CheckoutSession _tSession = CheckoutSession(
  url: 'https://checkout.stripe.test/cs_test_123',
  sessionId: 'cs_test_123',
  returnUrlMarker: '/stripe-return',
);

void main() {
  late _MockPaymentsDatasource datasource;
  late PaymentsRepositoryImpl repository;

  setUp(() {
    datasource = _MockPaymentsDatasource();
    repository = PaymentsRepositoryImpl(datasource);
  });

  group('createCheckout', () {
    test('devuelve la sesión que armó el datasource', () async {
      when(
        () => datasource.createCheckout(
          reservationId: any(named: 'reservationId'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      ).thenAnswer((_) async => _tSession);

      final Result<CheckoutSession> result = await repository.createCheckout(
        reservationId: 'res-1',
        wantInvoice: true,
      );

      expect(result, isA<Success<CheckoutSession>>());
      final CheckoutSession session =
          (result as Success<CheckoutSession>).data;
      expect(session.sessionId, 'cs_test_123');
      expect(session.returnUrlMarker, '/stripe-return');
      verify(
        () => datasource.createCheckout(
          reservationId: 'res-1',
          wantInvoice: true,
        ),
      ).called(1);
    });

    test('convierte el error del datasource en FailureResult', () async {
      when(
        () => datasource.createCheckout(
          reservationId: any(named: 'reservationId'),
          wantInvoice: any(named: 'wantInvoice'),
        ),
      ).thenThrow(const ServerFailure('Stripe no respondió'));

      final Result<CheckoutSession> result = await repository.createCheckout(
        reservationId: 'res-1',
        wantInvoice: false,
      );

      expect(result, isA<FailureResult<CheckoutSession>>());
      expect(
        (result as FailureResult<CheckoutSession>).failure,
        isA<ServerFailure>(),
      );
    });
  });

  group('verifyCheckout', () {
    test('traduce confirmed a reservationConfirmed', () async {
      when(
        () => datasource.verifyCheckout(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => PaymentVerificationMapper.toEntity(
          const RemotePaymentVerificationModel(paid: true, confirmed: false),
        ),
      );

      final Result<PaymentVerification> result = await repository
          .verifyCheckout(sessionId: 'cs_test_123');

      expect(result, isA<Success<PaymentVerification>>());
      final PaymentVerification verification =
          (result as Success<PaymentVerification>).data;
      expect(verification.paid, isTrue);
      expect(verification.reservationConfirmed, isFalse);
    });

    test('un error inesperado no se filtra crudo al dominio', () async {
      when(
        () => datasource.verifyCheckout(sessionId: any(named: 'sessionId')),
      ).thenThrow(Exception('boom'));

      final Result<PaymentVerification> result = await repository
          .verifyCheckout(sessionId: 'cs_test_123');

      expect(result, isA<FailureResult<PaymentVerification>>());
      expect(
        (result as FailureResult<PaymentVerification>).failure,
        isA<UnexpectedFailure>(),
      );
    });
  });

  test('CheckoutSessionMapper copia los tres campos', () {
    final CheckoutSession session = CheckoutSessionMapper.toEntity(_tModel);

    expect(session.url, _tModel.url);
    expect(session.sessionId, _tModel.sessionId);
    expect(session.returnUrlMarker, _tModel.returnUrlMarker);
  });
}
