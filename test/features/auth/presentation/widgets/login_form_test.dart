import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  ({List<String> emails, List<String> passwords}) submissions() =>
      (emails: <String>[], passwords: <String>[]);

  testWidgets('pinta los dos campos y el botón', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      LoginForm(loading: false, onSubmit: ({
        required String email,
        required String password,
      }) {}, onForgotPassword: () {}),
    );

    expect(find.byType(UiTextField), findsNWidgets(2));
    expect(find.widgetWithText(UiButton, 'Iniciar sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });

  testWidgets('la contraseña arranca oculta', (WidgetTester tester) async {
    await pumpComponent(
      tester,
      LoginForm(loading: false, onSubmit: ({
        required String email,
        required String password,
      }) {}, onForgotPassword: () {}),
    );

    final Iterable<EditableText> fields = tester.widgetList<EditableText>(
      find.byType(EditableText),
    );
    expect(fields.where((EditableText f) => f.obscureText), hasLength(1));
  });

  testWidgets('con el formulario vacío no envía y muestra los errores', (
    WidgetTester tester,
  ) async {
    bool submitted = false;
    await pumpComponent(
      tester,
      LoginForm(
        loading: false,
        onSubmit: ({required String email, required String password}) =>
            submitted = true,
        onForgotPassword: () {},
      ),
    );

    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pump();

    expect(submitted, isFalse);
    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('un correo mal formado no llega al provider', (
    WidgetTester tester,
  ) async {
    bool submitted = false;
    await pumpComponent(
      tester,
      LoginForm(
        loading: false,
        onSubmit: ({required String email, required String password}) =>
            submitted = true,
        onForgotPassword: () {},
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'victor');
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pump();

    expect(submitted, isFalse);
    expect(find.text('Correo inválido'), findsOneWidget);
  });

  testWidgets('una contraseña corta no llega al provider', (
    WidgetTester tester,
  ) async {
    bool submitted = false;
    await pumpComponent(
      tester,
      LoginForm(
        loading: false,
        onSubmit: ({required String email, required String password}) =>
            submitted = true,
        onForgotPassword: () {},
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'victor@correo.com',
    );
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pump();

    expect(submitted, isFalse);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
  });

  testWidgets('con datos válidos envía el correo recortado', (
    WidgetTester tester,
  ) async {
    final ({List<String> emails, List<String> passwords}) got = submissions();
    await pumpComponent(
      tester,
      LoginForm(
        loading: false,
        onSubmit: ({required String email, required String password}) {
          got.emails.add(email);
          got.passwords.add(password);
        },
        onForgotPassword: () {},
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      '  victor@correo.com  ',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secreta1');
    await tester.tap(find.widgetWithText(UiButton, 'Iniciar sesión'));
    await tester.pump();

    expect(got.emails, <String>['victor@correo.com']);
    // La contraseña NO se recorta: los espacios son parte del secreto.
    expect(got.passwords, <String>['secreta1']);
  });

  testWidgets('cargando bloquea "olvidé mi contraseña"', (
    WidgetTester tester,
  ) async {
    bool forgot = false;
    await pumpComponent(
      tester,
      LoginForm(
        loading: true,
        onSubmit: ({required String email, required String password}) {},
        onForgotPassword: () => forgot = true,
      ),
    );

    await tester.tap(find.byType(TextButton));

    expect(forgot, isFalse);
    expect(find.byType(UiLoader), findsOneWidget);
  });
}
