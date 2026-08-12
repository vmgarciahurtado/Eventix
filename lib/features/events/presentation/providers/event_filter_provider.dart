import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => const EventFilter();

  void setCategory(int? id) {
    state = EventFilter(
      categoryId: id,
      cityId: state.cityId,
      date: state.date,
    );
  }

  void setCity(int? id) {
    state = EventFilter(
      categoryId: state.categoryId,
      cityId: id,
      date: state.date,
    );
  }

  void setDate(DateTime? date) {
    state = EventFilter(
      categoryId: state.categoryId,
      cityId: state.cityId,
      date: date,
    );
  }

  void clear() => state = const EventFilter();
}

final NotifierProvider<EventFilterNotifier, EventFilter> eventFilterProvider =
    NotifierProvider<EventFilterNotifier, EventFilter>(
      EventFilterNotifier.new,
    );
