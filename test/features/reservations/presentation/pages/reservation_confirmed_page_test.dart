import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpConfirmed(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: ReservationConfirmedPage.routePath,
    routes: <RouteBase>[
      GoRoute(
        path: ReservationConfirmedPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            const ReservationConfirmedPage(),
      ),
      stubRoute(EventsPage.routePath, 'CATALOGO'),
      stubRoute(MyReservationsPage.routePath, 'RESERVAS'),
    ],
  );

  testWidgets('muestra la confirmación y sus dos salidas', (
    WidgetTester tester,
  ) async {
    await pumpConfirmed(tester);

    expect(
      find.textContaining('CONFIRMADO', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(UiButton, 'Ver mis reservas'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(UiButton, 'Seguir explorando'),
      findsOneWidget,
    );
  });

  testWidgets('el retroceso del sistema no sale de la pantalla', (
    WidgetTester tester,
  ) async {
    await pumpConfirmed(tester);

    // Se dispara el botón atrás del sistema por el mismo canal que usa el
    // motor: volver al formulario de reserva tras confirmar permitiría
    // reservar de nuevo sin darse cuenta.
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      null,
    );
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(UiButton, 'Ver mis reservas'),
      findsOneWidget,
    );
  });

  testWidgets('"seguir explorando" va al catálogo', (
    WidgetTester tester,
  ) async {
    await pumpConfirmed(tester);

    await tester.tap(find.widgetWithText(UiButton, 'Seguir explorando'));
    await tester.pumpAndSettle();

    expect(find.text('CATALOGO'), findsOneWidget);
  });

  testWidgets('"ver mis reservas" deja el catálogo debajo', (
    WidgetTester tester,
  ) async {
    await pumpConfirmed(tester);

    await tester.tap(find.widgetWithText(UiButton, 'Ver mis reservas'));
    await tester.pumpAndSettle();

    expect(find.text('RESERVAS'), findsOneWidget);

    // Con un `go` directo, reservas quedaría sola y el back cerraría la app.
    final BuildContext context = tester.element(find.text('RESERVAS'));
    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    expect(find.text('CATALOGO'), findsOneWidget);
  });
}
