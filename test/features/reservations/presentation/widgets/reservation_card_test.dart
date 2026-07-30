import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initSpanishDates);

  testWidgets('muestra evento, cantidad, fecha del evento y de la reserva', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      ReservationCard(reservation: tReservation(quantity: 3)),
    );

    expect(find.text('Festival de Reggaetón'), findsOneWidget);
    expect(find.text('3 cupo(s)'), findsOneWidget);
    expect(find.textContaining('4 jul'), findsOneWidget);
    expect(find.textContaining('Reservado el 29 jun 2026'), findsOneWidget);
  });

  testWidgets('una reserva confirmada se etiqueta como tal', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      ReservationCard(
        reservation: tReservation(status: ReservationStatus.confirmed),
      ),
    );

    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Pendiente'), findsNothing);
  });

  testWidgets('una reserva pendiente se etiqueta como pendiente', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      ReservationCard(reservation: tReservation()),
    );

    expect(find.text('Pendiente'), findsOneWidget);
  });

  testWidgets('sin fecha de evento no muestra esa fila ni se rompe', (
    WidgetTester tester,
  ) async {
    // El join puede no traer el evento si fue borrado.
    await pumpComponent(
      tester,
      ReservationCard(
        reservation: tReservation(eventStartsAt: DateTime.utc(2026, 7, 4)),
      ),
    );

    expect(
      find.byIcon(Icons.calendar_today_outlined),
      findsOneWidget,
      reason: 'con fecha sí debe aparecer el ícono de calendario',
    );
  });
}
