import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/events/presentation/widgets/event_detail_content.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initSpanishDates);

  Future<void> pumpDetail(
    WidgetTester tester,
    AsyncValue<int> available, {
    double price = 80000,
  }) => pumpRoutes(
    tester,
    initialLocation: '/detalle',
    routes: <RouteBase>[
      GoRoute(
        path: '/detalle',
        builder: (BuildContext context, GoRouterState state) =>
            EventDetailContent(
              event: tEvent(price: price),
              available: available,
            ),
      ),
      stubRoute(ReservePage.routePath, 'RESERVAR'),
    ],
  );

  testWidgets('muestra título, categoría, ciudad, fecha, precio y detalle', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, const AsyncData<int>(50));

    expect(find.text('Festival de Reggaetón'), findsOneWidget);
    expect(find.widgetWithText(UiChip, 'Reggaetón'), findsOneWidget);
    expect(find.widgetWithText(UiChip, 'Bogotá'), findsOneWidget);
    expect(find.textContaining('4 jul'), findsOneWidget);
    expect(find.text(r'$80.000'), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
  });

  testWidgets('mientras consulta cupos lo dice, sin inventar un número', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, const AsyncLoading<int>());

    expect(find.text('Consultando disponibilidad…'), findsOneWidget);
  });

  testWidgets('si falla la disponibilidad cae al aforo total', (
    WidgetTester tester,
  ) async {
    await pumpDetail(
      tester,
      const AsyncError<int>(ServerFailure(), StackTrace.empty),
    );

    // Mostrar el aforo es honesto; mostrar "0 cupos" por un error de red no.
    expect(find.text('Aforo: 300'), findsOneWidget);
  });

  testWidgets('con cupos, reservar abre el formulario de ese evento', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, const AsyncData<int>(12));

    expect(find.text('12 de 300 cupos disponibles'), findsOneWidget);
    await tester.tap(find.widgetWithText(UiButton, 'Reservar'));
    await tester.pumpAndSettle();

    expect(find.text('RESERVAR'), findsOneWidget);
  });

  testWidgets('agotado no deja reservar', (WidgetTester tester) async {
    await pumpDetail(tester, const AsyncData<int>(0));

    final UiButton button = tester.widget<UiButton>(
      find.widgetWithText(UiButton, 'Agotado'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('un evento gratuito muestra Gratis en la ficha', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, const AsyncData<int>(50), price: 0);

    expect(find.text('Gratis'), findsOneWidget);
  });
}
