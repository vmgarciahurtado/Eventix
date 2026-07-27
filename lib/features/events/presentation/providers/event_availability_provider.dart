import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Cupos libres: capacidad − reservas activas, calculado en BD.
final FutureProviderFamily<int, String> eventAvailabilityProvider =
    FutureProvider.family<int, String>((Ref ref, String id) async {
      final Result<int> result = await ref
          .watch(getEventAvailabilityProvider)
          .call(id);
      return switch (result) {
        Success<int>(:final int data) => data,
        FailureResult<int>(:final Failure failure) => throw failure,
      };
    });
