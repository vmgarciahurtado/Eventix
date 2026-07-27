import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

final FutureProviderFamily<Event, String> eventByIdProvider =
    FutureProvider.family<Event, String>((Ref ref, String id) async {
      final Result<Event> result = await ref
          .watch(getEventByIdProvider)
          .call(id);
      return switch (result) {
        Success<Event>(:final Event data) => data,
        FailureResult<Event>(:final Failure failure) => throw failure,
      };
    });
