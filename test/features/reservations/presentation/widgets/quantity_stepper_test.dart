import 'package:eventix/features/reservations/presentation/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Finder minus() => find.widgetWithIcon(IconButton, Icons.remove);
  Finder plus() => find.widgetWithIcon(IconButton, Icons.add);

  bool enabled(WidgetTester tester, Finder finder) =>
      tester.widget<IconButton>(finder).onPressed != null;

  testWidgets('muestra la cantidad actual', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      QuantityStepper(value: 3, max: 5, onChanged: (int _) {}),
    );

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('sumar y restar entregan el valor vecino', (
    WidgetTester tester,
  ) async {
    final List<int> changes = <int>[];
    await pumpComponent(
      tester,
      QuantityStepper(value: 3, max: 5, onChanged: changes.add),
    );

    await tester.tap(plus());
    await tester.tap(minus());

    expect(changes, <int>[4, 2]);
  });

  testWidgets('no baja de 1', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      QuantityStepper(value: 1, max: 5, onChanged: (int _) {}),
    );

    expect(enabled(tester, minus()), isFalse);
    expect(enabled(tester, plus()), isTrue);
  });

  testWidgets('no pasa del máximo', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      QuantityStepper(value: 5, max: 5, onChanged: (int _) {}),
    );

    expect(enabled(tester, plus()), isFalse);
    expect(enabled(tester, minus()), isTrue);
  });

  testWidgets('con un solo cupo disponible queda fijo en 1', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      QuantityStepper(value: 1, max: 1, onChanged: (int _) {}),
    );

    expect(enabled(tester, minus()), isFalse);
    expect(enabled(tester, plus()), isFalse);
  });

  testWidgets('sin onChanged queda deshabilitado por completo', (
    WidgetTester tester,
  ) async {
    // Es como la pantalla lo bloquea mientras corre la compra.
    await pumpComponent(
      tester,
      const QuantityStepper(value: 3, max: 5, onChanged: null),
    );

    expect(enabled(tester, minus()), isFalse);
    expect(enabled(tester, plus()), isFalse);
  });
}
