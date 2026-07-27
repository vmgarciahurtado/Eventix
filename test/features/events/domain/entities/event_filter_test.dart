import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventFilter.isEmpty', () {
    test('is true when no field is set', () {
      expect(const EventFilter().isEmpty, isTrue);
    });

    test('is false when any field is set', () {
      expect(const EventFilter(categoryId: 1).isEmpty, isFalse);
      expect(const EventFilter(cityId: 2).isEmpty, isFalse);
      expect(EventFilter(date: DateTime(2026, 7, 4)).isEmpty, isFalse);
    });
  });
}
