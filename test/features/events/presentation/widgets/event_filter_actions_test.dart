import 'dart:async';

import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:eventix/features/events/presentation/widgets/event_filter_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetCities extends Mock implements GetCities {}

void main() {
  late _MockGetCities getCities;

  setUpAll(initSpanishDates);

  setUp(() {
    getCities = _MockGetCities();
    when(
      getCities.call,
    ).thenAnswer((_) async => const Success<List<City>>(tCities));
  });

  /// Contenedor de providers del árbol montado, para leer el filtro resultante.
  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(
        tester.element(find.byType(EventFilterActions)),
      );

  Future<void> pumpActions(WidgetTester tester) async {
    await pumpComponent(
      tester,
      const EventFilterActions(),
      overrides: <Override>[
        getCitiesProvider.overrideWithValue(getCities),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin ciudad elegida muestra la etiqueta genérica', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    expect(find.text('Ciudad'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);
  });

  testWidgets('elegir una ciudad la deja en el filtro y en el botón', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    await tester.tap(find.text('Ciudad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bogotá').last);
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(eventFilterProvider).cityId, 1);
    expect(find.text('Bogotá'), findsOneWidget);
  });

  testWidgets('"Todas las ciudades" quita el filtro de ciudad', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);
    containerOf(tester).read(eventFilterProvider.notifier).setCity(1);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bogotá'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas las ciudades'));
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(eventFilterProvider).cityId, isNull);
  });

  testWidgets('cerrar el selector sin elegir deja el filtro como estaba', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    await tester.tap(find.text('Ciudad'));
    await tester.pumpAndSettle();
    // Tocar fuera del bottom sheet lo cierra devolviendo null.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(eventFilterProvider).cityId, isNull);
  });

  testWidgets('elegir una fecha la deja en el filtro y en el botón', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    await tester.tap(find.text('Fecha'));
    await tester.pumpAndSettle();
    // El calendario abre en hoy; mañana siempre está dentro del rango.
    final DateTime target = DateTime.now().add(const Duration(days: 1));
    await tester.tap(find.text('${target.day}').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();

    final DateTime? picked = containerOf(
      tester,
    ).read(eventFilterProvider).date;
    expect(picked, isNotNull);
    expect(picked!.day, target.day);
    expect(find.text('Fecha'), findsNothing);
  });

  testWidgets('cancelar el calendario no cambia el filtro', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);

    await tester.tap(find.text('Fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(eventFilterProvider).date, isNull);
    expect(find.text('Fecha'), findsOneWidget);
  });

  testWidgets('el botón de limpiar solo aparece con filtros puestos', (
    WidgetTester tester,
  ) async {
    await pumpActions(tester);
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);

    containerOf(tester).read(eventFilterProvider.notifier).setCity(1);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_off_outlined));
    await tester.pumpAndSettle();

    expect(
      containerOf(tester).read(eventFilterProvider),
      isA<EventFilter>().having(
        (EventFilter f) => f.isEmpty,
        'isEmpty',
        isTrue,
      ),
    );
  });

  testWidgets('mientras las ciudades cargan el botón queda deshabilitado', (
    WidgetTester tester,
  ) async {
    // Sin ciudades no hay nada que elegir: abriría una lista vacía.
    final Completer<Result<List<City>>> pending =
        Completer<Result<List<City>>>();
    when(getCities.call).thenAnswer((_) => pending.future);

    await pumpComponent(
      tester,
      const EventFilterActions(),
      overrides: <Override>[getCitiesProvider.overrideWithValue(getCities)],
    );
    await tester.pump();

    final OutlinedButton cityButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Ciudad'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(cityButton.onPressed, isNull);

    pending.complete(const Success<List<City>>(tCities));
    await tester.pumpAndSettle();
  });
}
