import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/filters_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:eventix/features/events/presentation/widgets/event_category_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetCategories extends Mock implements GetCategories {}

const List<Category> _catalog = <Category>[
  Category(id: 1, name: 'Reggaetón'),
  Category(id: 2, name: 'Electrónica'),
  Category(id: 3, name: 'Rock'),
];

FiltersConfig filtersWith({
  List<String> pinned = const <String>[],
  List<String> hidden = const <String>[],
}) => FiltersConfig(
  cityEnabled: true,
  dateEnabled: true,
  pinnedCategories: pinned,
  hiddenCategories: hidden,
);

void main() {
  late _MockGetCategories getCategories;

  setUp(() {
    getCategories = _MockGetCategories();
    when(getCategories.call).thenAnswer(
      (_) async => const Success<List<Category>>(_catalog),
    );
  });

  Future<void> pumpFilter(WidgetTester tester, {FiltersConfig? filters}) async {
    await pumpComponent(
      tester,
      const EventCategoryFilter(),
      overrides: <Override>[
        getCategoriesProvider.overrideWithValue(getCategories),
        if (filters != null) appConfigOverride(tAppConfig(filters: filters)),
      ],
    );
    await tester.pumpAndSettle();
  }

  /// Nombres de los chips en el orden en que se pintan.
  List<String> chipLabels(WidgetTester tester) => tester
      .widgetList<FilterChip>(find.byType(FilterChip))
      .map((FilterChip chip) => (chip.label as Text).data!)
      .toList();

  testWidgets('sin configuración respeta el orden del backend', (
    WidgetTester tester,
  ) async {
    await pumpFilter(tester);

    expect(chipLabels(tester), <String>[
      'Todas',
      'Reggaetón',
      'Electrónica',
      'Rock',
    ]);
  });

  testWidgets('las categorías fijadas suben en el orden del archivo', (
    WidgetTester tester,
  ) async {
    await pumpFilter(
      tester,
      filters: filtersWith(pinned: <String>['Rock', 'Electrónica']),
    );

    expect(chipLabels(tester), <String>[
      'Todas',
      'Rock',
      'Electrónica',
      'Reggaetón',
    ]);
  });

  testWidgets('las ocultas no se ofrecen aunque el backend las mande', (
    WidgetTester tester,
  ) async {
    await pumpFilter(tester, filters: filtersWith(hidden: <String>['Rock']));

    expect(chipLabels(tester), isNot(contains('Rock')));
    expect(chipLabels(tester), hasLength(3));
  });

  testWidgets('fijar una que no existe no rompe la lista', (
    WidgetTester tester,
  ) async {
    await pumpFilter(tester, filters: filtersWith(pinned: <String>['Salsa']));

    expect(chipLabels(tester), hasLength(4));
    expect(chipLabels(tester).first, 'Todas');
  });

  testWidgets('ocultar y fijar la misma categoría la deja fuera', (
    WidgetTester tester,
  ) async {
    await pumpFilter(
      tester,
      filters: filtersWith(pinned: <String>['Rock'], hidden: <String>['Rock']),
    );

    expect(chipLabels(tester), isNot(contains('Rock')));
  });

  testWidgets('tocar un chip deja su categoría en el filtro', (
    WidgetTester tester,
  ) async {
    await pumpFilter(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Electrónica'));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(EventCategoryFilter)),
    );
    expect(container.read(eventFilterProvider).categoryId, 2);
  });

  testWidgets('mientras el backend falla no se pintan chips', (
    WidgetTester tester,
  ) async {
    when(getCategories.call).thenAnswer(
      (_) async => const FailureResult<List<Category>>(ServerFailure()),
    );

    await pumpFilter(tester);

    expect(find.byType(FilterChip), findsNothing);
  });
}
