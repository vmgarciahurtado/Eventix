import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_empty_state.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:eventix/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetMyReservations extends Mock implements GetMyReservations {}

void main() {
  late _MockGetMyReservations getMyReservations;

  setUpAll(initSpanishDates);

  setUp(() => getMyReservations = _MockGetMyReservations());

  Future<void> pumpPageWith(
    WidgetTester tester,
    Result<List<Reservation>> result,
  ) {
    when(getMyReservations.call).thenAnswer((_) async => result);
    return pumpPage(
      tester,
      const MyReservationsPage(),
      overrides: <Override>[
        getMyReservationsProvider.overrideWithValue(getMyReservations),
      ],
    );
  }

  testWidgets('lista una tarjeta por reserva', (WidgetTester tester) async {
    await pumpPageWith(
      tester,
      Success<List<Reservation>>(<Reservation>[
        tReservation(eventTitle: 'Fiesta uno'),
        tReservation(
          id: 'res-2',
          eventTitle: 'Fiesta dos',
          status: ReservationStatus.confirmed,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReservationCard), findsNWidgets(2));
    expect(find.text('Fiesta uno'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  });

  testWidgets('sin reservas muestra el estado vacío', (
    WidgetTester tester,
  ) async {
    await pumpPageWith(tester, const Success<List<Reservation>>(
      <Reservation>[],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Cuando reserves un evento aparecerá aquí.'),
        findsOneWidget);
  });

  testWidgets('sin sesión muestra el mensaje de sesión expirada', (
    WidgetTester tester,
  ) async {
    await pumpPageWith(
      tester,
      const FailureResult<List<Reservation>>(UnauthorizedFailure()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AsyncErrorView), findsOneWidget);
    expect(find.text('Sesión expirada'), findsOneWidget);
  });

  testWidgets('actualizar vuelve a consultar', (WidgetTester tester) async {
    await pumpPageWith(tester, const Success<List<Reservation>>(
      <Reservation>[],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    verify(getMyReservations.call).called(2);
  });
}
