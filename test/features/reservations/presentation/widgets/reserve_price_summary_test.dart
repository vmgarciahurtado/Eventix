import 'package:eventix/features/reservations/presentation/widgets/reserve_price_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('muestra precio unitario y total', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      const ReservePriceSummary(unitPrice: 80000, total: 160000),
    );

    expect(find.text('Precio unitario'), findsOneWidget);
    expect(find.text(r'$80.000'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text(r'$160.000'), findsOneWidget);
  });

  testWidgets('un evento gratuito dice Gratis en las dos filas', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      const ReservePriceSummary(unitPrice: 0, total: 0),
    );

    expect(find.text('Gratis'), findsNWidgets(2));
  });
}
