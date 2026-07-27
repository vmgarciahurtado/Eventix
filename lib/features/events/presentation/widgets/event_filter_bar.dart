import 'package:eventix/features/events/presentation/widgets/event_category_filter.dart';
import 'package:eventix/features/events/presentation/widgets/event_filter_actions.dart';
import 'package:flutter/material.dart';

class EventFilterBar extends StatelessWidget {
  const EventFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[EventCategoryFilter(), EventFilterActions()],
    );
  }
}
