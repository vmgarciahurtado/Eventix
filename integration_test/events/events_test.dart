import '../exports.dart';

void main() {
  testWidgets('catálogo: trae eventos reales y los filtros reconsultan', (
    WidgetTester tester,
  ) async {
    if (skipWithoutSession()) return;

    await ensureSignedIn();
    await launchAt(tester, EventsPage.routePath);

    expect(find.byType(EventsPage), findsOneWidget);
    await waitForData(tester);

    // Ni loader colgado ni pantalla de error: el catálogo resolvió.
    expect(find.byType(AppLoadingView), findsNothing);
    expect(
      find.byType(AsyncErrorView),
      findsNothing,
      reason: 'el catálogo no debe quedar en error contra el backend real',
    );

    final bool hasEvents = find.byType(EventCard).evaluate().isNotEmpty;
    expect(
      hasEvents || find.byType(AppEmptyState).evaluate().isNotEmpty,
      isTrue,
      reason: 'o hay tarjetas, o el estado vacío; nunca una pantalla en blanco',
    );

    // Los chips salen del catálogo de categorías del backend.
    expect(find.widgetWithText(FilterChip, 'Todas'), findsOneWidget);

    final Iterable<FilterChip> chips = tester.widgetList<FilterChip>(
      find.byType(FilterChip),
    );
    expect(
      chips.length,
      greaterThan(1),
      reason: 'debe haber al menos una categoría además de "Todas"',
    );

    // Filtrar por la primera categoría real y volver a "Todas".
    final Finder firstCategory = find.byType(FilterChip).at(1);
    await tester.tap(firstCategory);
    await waitForData(tester);
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_off_outlined));
    await waitForData(tester);
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);

    // Actualizar no debe dejar la pantalla en error.
    await tester.tap(find.byIcon(Icons.refresh));
    await waitForData(tester);
    expect(find.byType(AsyncErrorView), findsNothing);
  });
}
