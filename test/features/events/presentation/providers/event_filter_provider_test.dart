import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  EventFilterNotifier notifier() =>
      container.read(eventFilterProvider.notifier);
  EventFilter filter() => container.read(eventFilterProvider);

  test('arranca sin filtros', () {
    expect(filter().isEmpty, isTrue);
  });

  test('cambiar la categoría no borra la ciudad ni la fecha', () {
    final DateTime date = DateTime.utc(2026, 7, 4);
    notifier().setCity(2);
    notifier().setDate(date);

    notifier().setCategory(1);

    // Cada setter reconstruye el filtro completo: olvidar un campo lo borraría.
    expect(filter().categoryId, 1);
    expect(filter().cityId, 2);
    expect(filter().date, date);
  });

  test('cambiar la ciudad no borra la categoría ni la fecha', () {
    final DateTime date = DateTime.utc(2026, 7, 4);
    notifier().setCategory(1);
    notifier().setDate(date);

    notifier().setCity(3);

    expect(filter().categoryId, 1);
    expect(filter().cityId, 3);
    expect(filter().date, date);
  });

  test('cambiar la fecha no borra la categoría ni la ciudad', () {
    notifier().setCategory(1);
    notifier().setCity(2);

    notifier().setDate(DateTime.utc(2026, 8, 15));

    expect(filter().categoryId, 1);
    expect(filter().cityId, 2);
    expect(filter().date, DateTime.utc(2026, 8, 15));
  });

  test('pasar null quita solo ese filtro', () {
    notifier().setCategory(1);
    notifier().setCity(2);

    notifier().setCategory(null);

    expect(filter().categoryId, isNull);
    expect(filter().cityId, 2);
    expect(filter().isEmpty, isFalse);
  });

  test('clear vuelve al filtro vacío', () {
    notifier().setCategory(1);
    notifier().setCity(2);
    notifier().setDate(DateTime.utc(2026, 7, 4));

    notifier().clear();

    expect(filter().isEmpty, isTrue);
  });
}
