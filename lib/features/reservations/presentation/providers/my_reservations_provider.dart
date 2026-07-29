import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `autoDispose` porque son datos del usuario en sesión: al salir de la
/// pantalla se descartan, así nunca los hereda la sesión siguiente.
final FutureProvider<List<Reservation>> myReservationsProvider =
    FutureProvider.autoDispose<List<Reservation>>((Ref ref) async {
      final Result<List<Reservation>> result = await ref
          .watch(getMyReservationsProvider)
          .call();
      return switch (result) {
        Success<List<Reservation>>(:final List<Reservation> data) => data,
        FailureResult<List<Reservation>>(:final Failure failure) =>
          throw failure,
      };
    });
