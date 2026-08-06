import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/auth/presentation/widgets/verify_code_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpForm(
    WidgetTester tester, {
    required List<String> submitted,
    bool loading = false,
    VoidCallback? onResend,
  }) => pumpComponent(
    tester,
    VerifyCodeForm(
      loading: loading,
      onSubmit: submitted.add,
      onResend: onResend ?? () {},
    ),
  );

  testWidgets('pinta tantas casillas como dígitos trae el código', (
    WidgetTester tester,
  ) async {
    // El bug: la constante existía pero el campo se quedaba en 6 casillas.
    await pumpForm(tester, submitted: <String>[]);

    expect(
      find.byType(TextField),
      findsNWidgets(VerifyCodeForm.otpLength),
    );
    expect(
      tester.widget<UiOtpField>(find.byType(UiOtpField)).length,
      VerifyCodeForm.otpLength,
    );
  });

  testWidgets('un código incompleto no se envía y avisa', (
    WidgetTester tester,
  ) async {
    final List<String> submitted = <String>[];
    await pumpForm(tester, submitted: submitted);

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.tap(find.widgetWithText(UiButton, 'Verificar'));
    await tester.pump();

    expect(submitted, isEmpty);
    expect(find.text('Ingresa el código completo'), findsOneWidget);
  });

  testWidgets('completar todas las casillas envía el código solo', (
    WidgetTester tester,
  ) async {
    final List<String> submitted = <String>[];
    await pumpForm(tester, submitted: submitted);

    for (int i = 0; i < VerifyCodeForm.otpLength; i++) {
      await tester.enterText(find.byType(TextField).at(i), '$i');
      await tester.pump();
    }

    expect(submitted, <String>['01234567']);
  });

  testWidgets('no envía dos veces el mismo código completo', (
    WidgetTester tester,
  ) async {
    final List<String> submitted = <String>[];
    await pumpForm(tester, submitted: submitted);

    for (int i = 0; i < VerifyCodeForm.otpLength; i++) {
      await tester.enterText(find.byType(TextField).at(i), '1');
      await tester.pump();
    }
    // El autoenvío ya disparó; tocar el botón no debe repetirlo.
    await tester.tap(find.widgetWithText(UiButton, 'Verificar'));
    await tester.pump();

    expect(submitted, hasLength(2));
    expect(submitted.first, submitted.last);
  });

  testWidgets('cargando bloquea el reenvío', (WidgetTester tester) async {
    bool resent = false;
    await pumpForm(
      tester,
      submitted: <String>[],
      loading: true,
      onResend: () => resent = true,
    );

    await tester.tap(find.text('Reenviar código'));

    expect(resent, isFalse);
  });

  testWidgets('sin cargar, el reenvío funciona', (WidgetTester tester) async {
    bool resent = false;
    await pumpForm(
      tester,
      submitted: <String>[],
      onResend: () => resent = true,
    );

    await tester.tap(find.text('Reenviar código'));

    expect(resent, isTrue);
  });
}
