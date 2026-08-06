import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// Lo que el formulario entregó al provider, en orden de campo.
typedef _Submission =
    ({String email, String password, String firstName, String lastName});

void main() {
  late List<_Submission> submissions;

  setUp(() => submissions = <_Submission>[]);

  Future<void> pumpForm(WidgetTester tester, {bool loading = false}) =>
      pumpComponent(
        tester,
        RegisterForm(
          loading: loading,
          onSubmit: ({
            required String email,
            required String password,
            required String firstName,
            required String lastName,
          }) => submissions.add((
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          )),
        ),
      );

  Future<void> fill(
    WidgetTester tester, {
    String firstName = 'Victor',
    String lastName = 'García',
    String email = 'victor@correo.com',
    String password = 'secreta1',
    String? confirm,
  }) async {
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), firstName);
    await tester.enterText(fields.at(1), lastName);
    await tester.enterText(fields.at(2), email);
    await tester.enterText(fields.at(3), password);
    await tester.enterText(fields.at(4), confirm ?? password);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(UiButton, 'Registrarme'));
    await tester.pump();
  }

  /// Toca el indicador, no el centro de la fila: ahí está el enlace a términos.
  Future<void> acceptTerms(WidgetTester tester) async {
    await tester.tapAt(
      tester.getTopLeft(find.byType(UiCheckOption)) + const Offset(12, 12),
    );
    await tester.pump();
  }

  testWidgets('pinta los cinco campos y la aceptación de términos', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.byType(UiTextField), findsNWidgets(5));
    expect(find.byType(UiCheckOption), findsOneWidget);
    expect(
      find.textContaining('términos y condiciones', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('vacío muestra un error por campo obligatorio', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await submit(tester);

    expect(submissions, isEmpty);
    expect(find.text('Ingresa tu nombre'), findsOneWidget);
    expect(find.text('Ingresa tu apellido'), findsOneWidget);
    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.text('Confirma tu contraseña'), findsOneWidget);
  });

  testWidgets('si las contraseñas no coinciden no envía', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await fill(tester, confirm: 'secreta2');
    await submit(tester);

    expect(submissions, isEmpty);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets('con todo válido pero sin aceptar términos no envía', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await fill(tester);
    await submit(tester);

    expect(submissions, isEmpty);
    expect(
      find.text('Debes aceptar los términos y condiciones'),
      findsOneWidget,
    );
  });

  testWidgets('con todo válido y términos aceptados envía recortado', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await fill(
      tester,
      firstName: '  Victor  ',
      email: '  victor@correo.com  ',
    );
    await acceptTerms(tester);
    await submit(tester);

    expect(submissions, hasLength(1));
    expect(submissions.single.firstName, 'Victor');
    expect(submissions.single.email, 'victor@correo.com');
    expect(submissions.single.password, 'secreta1');
  });

  testWidgets('cargando muestra el loader en el botón', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, loading: true);

    expect(find.byType(UiLoader), findsOneWidget);
    expect(find.text('Registrarme'), findsNothing);
  });
}
