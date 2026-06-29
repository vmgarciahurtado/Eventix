import 'package:eventix/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure.userMessage', () {
    group('default messages', () {
      test(
        'given ConnectionFailure with no argument '
        'when userMessage is read '
        'then returns the default connection message',
        () {
          const ConnectionFailure failure = ConnectionFailure();
          expect(failure.userMessage, 'Sin conexión a internet');
        },
      );

      test(
        'given ServerFailure with no argument '
        'when userMessage is read '
        'then returns the default server message',
        () {
          const ServerFailure failure = ServerFailure();
          expect(
            failure.userMessage,
            'Error del servidor. Intenta de nuevo más tarde.',
          );
        },
      );

      test(
        'given NotFoundFailure with no argument '
        'when userMessage is read '
        'then returns the default not found message',
        () {
          const NotFoundFailure failure = NotFoundFailure();
          expect(failure.userMessage, 'Recurso no encontrado');
        },
      );

      test(
        'given UnauthorizedFailure with no argument '
        'when userMessage is read '
        'then returns the default unauthorized message',
        () {
          const UnauthorizedFailure failure = UnauthorizedFailure();
          expect(failure.userMessage, 'Sesión expirada');
        },
      );

      test(
        'given UnexpectedFailure with no argument '
        'when userMessage is read '
        'then returns the default unexpected message',
        () {
          const UnexpectedFailure failure = UnexpectedFailure();
          expect(failure.userMessage, 'Error inesperado');
        },
      );
    });

    group('custom messages', () {
      test(
        'given ConnectionFailure with a custom message '
        'when userMessage is read '
        'then returns the custom message',
        () {
          const ConnectionFailure failure = ConnectionFailure('custom');
          expect(failure.userMessage, 'custom');
        },
      );

      test(
        'given ServerFailure with a custom message '
        'when userMessage is read '
        'then returns the custom message',
        () {
          const ServerFailure failure = ServerFailure('custom');
          expect(failure.userMessage, 'custom');
        },
      );

      test(
        'given NotFoundFailure with a custom message '
        'when userMessage is read '
        'then returns the custom message',
        () {
          const NotFoundFailure failure = NotFoundFailure('custom');
          expect(failure.userMessage, 'custom');
        },
      );

      test(
        'given UnauthorizedFailure with a custom message '
        'when userMessage is read '
        'then returns the custom message',
        () {
          const UnauthorizedFailure failure = UnauthorizedFailure('custom');
          expect(failure.userMessage, 'custom');
        },
      );

      test(
        'given UnexpectedFailure with a custom message '
        'when userMessage is read '
        'then returns the custom message',
        () {
          const UnexpectedFailure failure = UnexpectedFailure('custom');
          expect(failure.userMessage, 'custom');
        },
      );
    });
  });
}
