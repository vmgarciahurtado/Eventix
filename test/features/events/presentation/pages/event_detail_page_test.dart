import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/widgets/event_detail_content.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetEventById extends Mock implements GetEventById {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

void main() {
  late _MockGetEventById getEventById;
  late _MockGetEventAvailability getAvailability;

  setUpAll(initSpanishDates);

  setUp(() {
    getEventById = _MockGetEventById();
    getAvailability = _MockGetEventAvailability();
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => const Success<int>(25));
  });

  Future<void> pumpDetail(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: EventDetailPage.location('evt-1'),
    overrides: <Override>[
      getEventByIdProvider.overrideWithValue(getEventById),
      getEventAvailabilityProvider.overrideWithValue(getAvailability),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: EventDetailPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            EventDetailPage(eventId: state.pathParameters['id']!),
      ),
      stubRoute(ReservePage.routePath, 'RESERVAR'),
    ],
  );

  testWidgets('mientras carga muestra el loader del sistema de diseño', (
    WidgetTester tester,
  ) async {
    when(
      () => getEventById.call(any()),
    ).thenAnswer((_) async => Success<Event>(tEvent()));

    await pumpDetail(tester);

    expect(find.byType(UiLoader), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('carga el evento del id de la ruta y muestra su ficha', (
    WidgetTester tester,
  ) async {
    when(
      () => getEventById.call(any()),
    ).thenAnswer((_) async => Success<Event>(tEvent()));

    await pumpDetail(tester);
    await tester.pumpAndSettle();

    verify(() => getEventById.call('evt-1')).called(1);
    expect(find.byType(EventDetailContent), findsOneWidget);
    expect(find.text('25 de 300 cupos disponibles'), findsOneWidget);
  });

  testWidgets('un evento inexistente muestra el error con reintento', (
    WidgetTester tester,
  ) async {
    when(() => getEventById.call(any())).thenAnswer(
      (_) async => const FailureResult<Event>(NotFoundFailure()),
    );

    await pumpDetail(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AsyncErrorView), findsOneWidget);
    expect(find.text('Recurso no encontrado'), findsOneWidget);
  });

  testWidgets('reintentar tras el error vuelve a consultar', (
    WidgetTester tester,
  ) async {
    when(() => getEventById.call(any())).thenAnswer(
      (_) async => const FailureResult<Event>(ServerFailure()),
    );

    await pumpDetail(tester);
    await tester.pumpAndSettle();

    when(
      () => getEventById.call(any()),
    ).thenAnswer((_) async => Success<Event>(tEvent()));
    await tester.tap(find.widgetWithText(UiButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(EventDetailContent), findsOneWidget);
  });

  testWidgets('mantiene el AppBar en el error para poder volver atrás', (
    WidgetTester tester,
  ) async {
    when(() => getEventById.call(any())).thenAnswer(
      (_) async => const FailureResult<Event>(ServerFailure()),
    );

    await pumpDetail(tester);
    await tester.pumpAndSettle();

    // Sin AppBar el usuario quedaría encerrado en la pantalla de error.
    expect(find.byType(AppBar), findsOneWidget);
  });
}
