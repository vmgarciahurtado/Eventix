import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/core/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pumpView(
    WidgetTester tester,
    AsyncValue<String> value, {
    VoidCallback? onRetry,
    String? loadingLabel,
  }) => pumpComponent(
    tester,
    AsyncView<String>(
      value: value,
      onRetry: onRetry,
      loadingLabel: loadingLabel,
      data: (String data) => Text(data),
    ),
  );

  testWidgets('cargando muestra el loader de la marca', (
    WidgetTester tester,
  ) async {
    await pumpView(tester, const AsyncLoading<String>());

    expect(find.byType(AppLoadingView), findsOneWidget);
    expect(find.text('CARGANDO…'), findsOneWidget);
  });

  testWidgets('acepta una etiqueta propia de carga', (
    WidgetTester tester,
  ) async {
    await pumpView(
      tester,
      const AsyncLoading<String>(),
      loadingLabel: 'Buscando eventos',
    );

    expect(find.text('BUSCANDO EVENTOS'), findsOneWidget);
  });

  testWidgets('con datos entrega el contenido al builder', (
    WidgetTester tester,
  ) async {
    await pumpView(tester, const AsyncData<String>('listo'));

    expect(find.text('listo'), findsOneWidget);
    expect(find.byType(AppLoadingView), findsNothing);
  });

  testWidgets('un Failure muestra su mensaje al usuario', (
    WidgetTester tester,
  ) async {
    await pumpView(
      tester,
      const AsyncError<String>(ConnectionFailure(), StackTrace.empty),
    );

    expect(find.byType(AsyncErrorView), findsOneWidget);
    expect(find.text('Sin conexión a internet'), findsOneWidget);
  });

  testWidgets('un error que no es Failure usa el mensaje genérico', (
    WidgetTester tester,
  ) async {
    // Nunca se filtra un stack trace o un detalle técnico a la pantalla.
    await pumpView(
      tester,
      AsyncError<String>(
        StateError('Bad state: internal thing exploded'),
        StackTrace.empty,
      ),
    );

    expect(find.text('Ocurrió un error inesperado'), findsOneWidget);
    expect(find.textContaining('internal thing'), findsNothing);
  });

  testWidgets('un UnexpectedFailure tampoco muestra su detalle técnico', (
    WidgetTester tester,
  ) async {
    await pumpView(
      tester,
      const AsyncError<String>(
        UnexpectedFailure('PostgrestException code 42P01'),
        StackTrace.empty,
      ),
    );

    expect(find.text('Algo salió mal. Intenta de nuevo.'), findsOneWidget);
    expect(find.textContaining('42P01'), findsNothing);
  });

  testWidgets('con onRetry ofrece reintentar y lo ejecuta', (
    WidgetTester tester,
  ) async {
    int retries = 0;
    await pumpView(
      tester,
      const AsyncError<String>(ServerFailure(), StackTrace.empty),
      onRetry: () => retries++,
    );

    await tester.tap(find.widgetWithText(UiButton, 'Reintentar'));

    expect(retries, 1);
  });

  testWidgets('sin onRetry no ofrece el botón', (WidgetTester tester) async {
    await pumpView(
      tester,
      const AsyncError<String>(ServerFailure(), StackTrace.empty),
    );

    expect(find.text('Reintentar'), findsNothing);
  });
}
