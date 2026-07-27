import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listado principal: se recalcula solo cuando cambia [eventFilterProvider].
final FutureProvider<List<Event>> eventsProvider = FutureProvider<List<Event>>((
  Ref ref,
) async {
  final EventFilter filter = ref.watch(eventFilterProvider);
  final Result<List<Event>> result = await ref
      .watch(getEventsProvider)
      .call(filter);
  return switch (result) {
    Success<List<Event>>(:final List<Event> data) => data,
    FailureResult<List<Event>>(:final Failure failure) => throw failure,
  };
});
