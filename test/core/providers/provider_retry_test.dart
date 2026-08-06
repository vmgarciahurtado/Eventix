import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/presentation/providers/events_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_container.dart';

class _MockGetEvents extends Mock implements GetEvents {}

/// Riverpod 3 reintenta los throwables que no son `Error`: mientras lo hace
/// el estado sigue en `AsyncLoading` y la pantalla no muestra el error.
void main() {
  late _MockGetEvents getEvents;

  setUpAll(() => registerFallbackValue(const EventFilter()));

  setUp(() => getEvents = _MockGetEvents());

  Override override() => getEventsProvider.overrideWithValue(getEvents);

  test('tras un Failure el estado sigue en carga, no en error', () async {
    when(() => getEvents.call(any())).thenAnswer(
      (_) async => const FailureResult<List<Event>>(ConnectionFailure()),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[override()],
    );
    addTearDown(container.dispose);
    keepAlive(container, eventsProvider);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(eventsProvider), isA<AsyncLoading<List<Event>>>());
  });

  test('vuelve a consultar solo, sin que el usuario toque nada', () async {
    when(() => getEvents.call(any())).thenAnswer(
      (_) async => const FailureResult<List<Event>>(ConnectionFailure()),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[override()],
    );
    addTearDown(container.dispose);
    keepAlive(container, eventsProvider);

    // El primer backoff es de 200 ms.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    verify(() => getEvents.call(any())).called(greaterThan(1));
  });

  test('con los reintentos apagados el error aparece de inmediato', () async {
    when(() => getEvents.call(any())).thenAnswer(
      (_) async => const FailureResult<List<Event>>(ConnectionFailure()),
    );
    final ProviderContainer container = testContainer(
      overrides: <Override>[override()],
    );
    addTearDown(container.dispose);
    keepAlive(container, eventsProvider);

    await Future<void>.delayed(Duration.zero);

    expect(container.read(eventsProvider), isA<AsyncError<List<Event>>>());
  });

  test('un reintento exitoso resuelve sin intervención del usuario', () async {
    int calls = 0;
    when(() => getEvents.call(any())).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? const FailureResult<List<Event>>(ConnectionFailure())
          : Success<List<Event>>(<Event>[tEvent()]);
    });
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[override()],
    );
    addTearDown(container.dispose);
    keepAlive(container, eventsProvider);

    expect(await container.read(eventsProvider.future), hasLength(1));
  });
}
