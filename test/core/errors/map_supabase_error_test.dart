import 'dart:async';
import 'dart:io';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/map_supabase_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapSupabaseError', () {
    test('returns the same Failure when the error already is one', () {
      const Failure original = NotFoundFailure();
      expect(mapSupabaseError(original), same(original));
    });

    test(
      'maps AuthRetryableFetchException (network) to ConnectionFailure '
      'before the generic AuthException branch',
      () {
        // Es el bug que se corrigió: sin conexión, gotrue envuelve el
        // SocketException en AuthRetryableFetchException (que extiende
        // AuthException). Debe aterrizar como ConnectionFailure, no como
        // AuthFailure con el texto técnico crudo.
        final Failure failure = mapSupabaseError(
          AuthRetryableFetchException(
            message: 'ClientException with SocketException: Failed host lookup',
          ),
        );
        expect(failure, isA<ConnectionFailure>());
      },
    );

    test('maps AuthException to a translated AuthFailure', () {
      final Failure failure = mapSupabaseError(
        const AuthException('Invalid login credentials'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.userMessage, 'Correo o contraseña incorrectos.');
    });

    test('keeps the raw auth message when there is no known translation', () {
      final Failure failure = mapSupabaseError(
        const AuthException('Some unmapped auth error'),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.userMessage, 'Some unmapped auth error');
    });

    test('maps FunctionException using its { error } detail', () {
      final Failure failure = mapSupabaseError(
        const FunctionException(
          status: 400,
          details: <String, dynamic>{'error': 'Este evento es gratuito.'},
        ),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.userMessage, 'Este evento es gratuito.');
    });

    test('maps FunctionException without detail to a generic message', () {
      final Failure failure = mapSupabaseError(
        const FunctionException(status: 500),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.userMessage, 'No se pudo completar la operación.');
    });

    test('maps PGRST116 / 404 Postgrest codes to NotFoundFailure', () {
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'no rows', code: 'PGRST116'),
        ),
        isA<NotFoundFailure>(),
      );
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'not found', code: '404'),
        ),
        isA<NotFoundFailure>(),
      );
    });

    test('maps PGRST301 / 42501 to UnauthorizedFailure', () {
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'jwt expired', code: 'PGRST301'),
        ),
        isA<UnauthorizedFailure>(),
      );
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'denied', code: '42501'),
        ),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps unique-violation (23505) to ValidationFailure', () {
      final Failure failure = mapSupabaseError(
        const PostgrestException(message: 'duplicate', code: '23505'),
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure.userMessage, 'El registro ya existe.');
    });

    test('maps check/foreign-key violations (23514/23503) to Validation', () {
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'check', code: '23514'),
        ),
        isA<ValidationFailure>(),
      );
      expect(
        mapSupabaseError(
          const PostgrestException(message: 'fk', code: '23503'),
        ),
        isA<ValidationFailure>(),
      );
    });

    test(
      'maps P0001 (trigger raise, e.g. no capacity) to ValidationFailure '
      'exposing the business message',
      () {
        final Failure failure = mapSupabaseError(
          const PostgrestException(
            message: 'No hay cupos suficientes para este evento',
            code: 'P0001',
          ),
        );
        expect(failure, isA<ValidationFailure>());
        expect(
          failure.userMessage,
          'No hay cupos suficientes para este evento',
        );
      },
    );

    test('maps an unknown Postgrest code to ServerFailure', () {
      final Failure failure = mapSupabaseError(
        const PostgrestException(message: 'boom', code: '12345'),
      );
      expect(failure, isA<ServerFailure>());
    });

    test('maps SocketException and TimeoutException to ConnectionFailure', () {
      expect(
        mapSupabaseError(const SocketException('no route')),
        isA<ConnectionFailure>(),
      );
      expect(
        mapSupabaseError(TimeoutException('slow')),
        isA<ConnectionFailure>(),
      );
    });

    test('falls back to UnexpectedFailure for anything else', () {
      final Failure failure = mapSupabaseError(
        ArgumentError('totally unexpected'),
      );
      expect(failure, isA<UnexpectedFailure>());
      // El detalle técnico queda para logs, no se filtra al usuario.
      expect(
        failure.userMessage,
        isNot(contains('totally unexpected')),
      );
    });
  });
}
