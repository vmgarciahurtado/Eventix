import 'package:eventix/features/reservations/presentation/widgets/reserve_event_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initSpanishDates);

  Future<void> pumpHeader(
    WidgetTester tester,
    AsyncValue<int> available,
  ) async {
    await pumpComponent(
      tester,
      ReserveEventHeader(
        event: tEvent(title: 'Festival'),
        available: available,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('con cupos muestra cuántos quedan sobre el aforo', (
    WidgetTester tester,
  ) async {
    await pumpHeader(tester, const AsyncData<int>(42));

    expect(find.text('Festival'), findsOneWidget);
    expect(find.text('42 de 300 cupos disponibles'), findsOneWidget);
  });

  testWidgets('sin cupos lo dice sin números', (WidgetTester tester) async {
    await pumpHeader(tester, const AsyncData<int>(0));

    expect(find.text('Agotado'), findsOneWidget);
  });

  testWidgets('mientras consulta lo anuncia', (WidgetTester tester) async {
    await pumpHeader(tester, const AsyncLoading<int>());

    expect(find.text('Consultando disponibilidad…'), findsOneWidget);
  });

  testWidgets('si la consulta falla cae al aforo total', (
    WidgetTester tester,
  ) async {
    await pumpHeader(
      tester,
      AsyncError<int>(Exception('sin red'), StackTrace.empty),
    );

    expect(find.text('Aforo: 300'), findsOneWidget);
    expect(find.text('Agotado'), findsNothing);
  });
}
